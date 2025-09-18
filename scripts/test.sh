#!/bin/bash
set -euxo pipefail

ENV=${ENV:-production}
INVENTORY="inventories/${ENV}/hosts.yml"
IMAGE=${OPENWRT_IMAGE:-openwrt/rootfs:x86_64-23.05.6}
ARTIFACT_DIR=${ARTIFACT_DIR:-}

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command is required to run the role tests" >&2
  exit 127
fi

if [ ! -f "$INVENTORY" ]; then
  echo "Inventory $INVENTORY not found" >&2
  exit 1
fi

TMPDIR=$(mktemp -d)
declare -a CONTAINERS=()

if [ -n "$ARTIFACT_DIR" ]; then
  case "$ARTIFACT_DIR" in
    "."|"./"|"/"|".."|"../"*)
      echo "Refusing to use $ARTIFACT_DIR as artifact directory" >&2
      exit 1
      ;;
  esac
  mkdir -p "$ARTIFACT_DIR"
  find "$ARTIFACT_DIR" -mindepth 1 -delete
fi

archive_logs() {
  local bucket=$1
  shift

  [ -n "$ARTIFACT_DIR" ] || return 0
  mkdir -p "$ARTIFACT_DIR/$bucket"

  for log in "$@"; do
    if [ -f "$log" ]; then
      cp "$log" "$ARTIFACT_DIR/$bucket/"
    fi
  done
}

cleanup() {
  if [ ${#CONTAINERS[@]} -gt 0 ]; then
    docker rm -f "${CONTAINERS[@]}" >/dev/null 2>&1 || true
  fi
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

for role in roles/*; do
  [ -d "$role" ] || continue
  role_name=$(basename "$role")
  echo "Testing role: $role_name"
  CONTAINER_NAME="test-${role_name}-$$"
  CONTAINERS+=("$CONTAINER_NAME")

  docker run -d --rm --name "$CONTAINER_NAME" --label openwrt-ansible-ci="role-test" \
    "$IMAGE" /sbin/init >/dev/null
  docker exec "$CONTAINER_NAME" opkg update
  docker exec "$CONTAINER_NAME" opkg install python3

  inventory_file="$TMPDIR/inventory.docker"
  role_playbook="$TMPDIR/role.yml"
  first_log="$TMPDIR/${role_name}-first.log"
  second_log="$TMPDIR/${role_name}-second.log"

  cat <<EOT >"$inventory_file"
[openwrt]
$CONTAINER_NAME ansible_connection=community.docker.docker ansible_python_interpreter=/usr/bin/python3
EOT

  cat <<EOT >"$role_playbook"
- hosts: openwrt
  gather_facts: false
  roles:
    - $role_name
EOT

  EXTRA_VARS=""
  if [ "$role_name" = "backup" ]; then
    EXTRA_VARS="backup_enabled=true backup_run_on_change=false"
  fi

  if ! ansible-playbook -vv -i "$inventory_file" ${EXTRA_VARS:+--extra-vars "$EXTRA_VARS"} \
    "$role_playbook" >"$first_log" 2>&1; then
    echo "First run failed for role $role_name"
    cat "$first_log"
    archive_logs "$role_name" "$first_log" "$second_log"
    exit 1
  fi

  if ! ansible-playbook -vv -i "$inventory_file" ${EXTRA_VARS:+--extra-vars "$EXTRA_VARS"} \
    "$role_playbook" >"$second_log" 2>&1; then
    echo "Second run failed for role $role_name"
    cat "$second_log"
    archive_logs "$role_name" "$first_log" "$second_log"
    exit 1
  fi

  if ! grep -q 'changed=0.*failed=0' "$second_log"; then
    echo "Role $role_name is not idempotent"
    cat "$second_log"
    archive_logs "$role_name" "$first_log" "$second_log"
    exit 1
  fi

  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  for i in "${!CONTAINERS[@]}"; do
    if [ "${CONTAINERS[$i]}" = "$CONTAINER_NAME" ]; then
      unset 'CONTAINERS[$i]'
    fi
  done
  rm -f "$inventory_file" "$role_playbook" "$first_log" "$second_log"
done

bootstrap_log="$TMPDIR/bootstrap.log"
site_log="$TMPDIR/site.log"

if ! ansible-playbook -i "$INVENTORY" --syntax-check playbooks/bootstrap.yml \
  >"$bootstrap_log" 2>&1; then
  echo "Syntax check failed for playbooks/bootstrap.yml"
  cat "$bootstrap_log"
  archive_logs playbooks "$bootstrap_log"
  exit 1
fi

if ! ansible-playbook -i "$INVENTORY" --syntax-check playbooks/site.yml \
  >"$site_log" 2>&1; then
  echo "Syntax check failed for playbooks/site.yml"
  cat "$site_log"
  archive_logs playbooks "$bootstrap_log" "$site_log"
  exit 1
fi

CONTAINER_NAME="openwrt-test-$$"
CONTAINERS+=("$CONTAINER_NAME")
docker run -d --rm --name "$CONTAINER_NAME" --label openwrt-ansible-ci="playbook-test" \
  "$IMAGE" /sbin/init >/dev/null
docker exec "$CONTAINER_NAME" opkg update
docker exec "$CONTAINER_NAME" opkg install python3

inventory_file="$TMPDIR/playbook-inventory.docker"
cat <<EOT >"$inventory_file"
[openwrt]
$CONTAINER_NAME ansible_connection=community.docker.docker ansible_python_interpreter=/usr/bin/python3
[openwrt:vars]
backup_enabled=false
EOT

bootstrap_apply_log="$TMPDIR/playbook-bootstrap.log"
site_apply_log="$TMPDIR/playbook-site.log"

if ! ansible-playbook -i "$inventory_file" playbooks/bootstrap.yml \
  >"$bootstrap_apply_log" 2>&1; then
  echo "Playbook bootstrap run failed"
  cat "$bootstrap_apply_log"
  archive_logs playbooks "$bootstrap_log" "$bootstrap_apply_log"
  exit 1
fi

if ! ansible-playbook -i "$inventory_file" playbooks/site.yml \
  >"$site_apply_log" 2>&1; then
  echo "Playbook site run failed"
  cat "$site_apply_log"
  archive_logs playbooks "$bootstrap_log" "$site_apply_log"
  exit 1
fi

docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
for i in "${!CONTAINERS[@]}"; do
  if [ "${CONTAINERS[$i]}" = "$CONTAINER_NAME" ]; then
    unset 'CONTAINERS[$i]'
  fi
done
rm -f "$inventory_file"
