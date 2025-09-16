#!/bin/bash
set -euxo pipefail

ENV=${ENV:-lab}
INVENTORY="inventories/${ENV}/hosts.yml"
IMAGE=${OPENWRT_IMAGE:-openwrt/rootfs:x86_64-23.05.6}

if ! command -v docker >/dev/null 2>&1; then
  echo "docker command is required to run the role tests" >&2
  exit 127
fi

TMPDIR=$(mktemp -d)
declare -a CONTAINERS=()

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
    EXTRA_VARS="backup_enabled=true"
  fi

  ansible-playbook -vv -i "$inventory_file" ${EXTRA_VARS:+--extra-vars "$EXTRA_VARS"} \
    "$role_playbook" >"$first_log"
  second_run=$(ansible-playbook -vv -i "$inventory_file" ${EXTRA_VARS:+--extra-vars "$EXTRA_VARS"} \
    "$role_playbook")
  echo "$second_run" >"$second_log"

  if ! echo "$second_run" | grep -q 'changed=0.*failed=0'; then
    echo "Role $role_name is not idempotent"
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

ansible-playbook -i "$INVENTORY" --syntax-check playbooks/bootstrap.yml
ansible-playbook -i "$INVENTORY" --syntax-check playbooks/site.yml

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

ansible-playbook -i "$inventory_file" playbooks/bootstrap.yml
ansible-playbook -i "$inventory_file" playbooks/site.yml

docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
for i in "${!CONTAINERS[@]}"; do
  if [ "${CONTAINERS[$i]}" = "$CONTAINER_NAME" ]; then
    unset 'CONTAINERS[$i]'
  fi
done
rm -f "$inventory_file"
