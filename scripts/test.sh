#!/bin/bash
set -euxo pipefail

ENV=${ENV:-lab}
INVENTORY="inventories/${ENV}/hosts.yml"
IMAGE=${OPENWRT_IMAGE:-openwrt/rootfs:x86_64-23.05.6}

for role in roles/*; do
  role_name=$(basename "$role")
  echo "Testing role: $role_name"
  CONTAINER_NAME="test-${role_name}"
  docker run -d --rm --name "$CONTAINER_NAME" "$IMAGE" /sbin/init >/dev/null
  docker exec "$CONTAINER_NAME" opkg update
  docker exec "$CONTAINER_NAME" opkg install python3 cron
  cat <<EOT >/tmp/inventory.docker
[openwrt]
$CONTAINER_NAME ansible_connection=community.docker.docker ansible_python_interpreter=/usr/bin/python3
EOT
  cat <<EOT >/tmp/role.yml
- hosts: openwrt
  gather_facts: false
  roles:
    - $role_name
EOT
  EXTRA_VARS=""
  if [ "$role_name" = "backup" ]; then
    EXTRA_VARS="backup_enabled=true"
  fi
  ansible-playbook -vv -i /tmp/inventory.docker ${EXTRA_VARS:+--extra-vars "$EXTRA_VARS"} /tmp/role.yml >/tmp/first.log
  second_run=$(ansible-playbook -vv -i /tmp/inventory.docker ${EXTRA_VARS:+--extra-vars "$EXTRA_VARS"} /tmp/role.yml)
  echo "$second_run" >/tmp/second.log
  if ! echo "$second_run" | grep -q 'changed=0.*failed=0'; then
    echo "Role $role_name is not idempotent"
    exit 1
  fi
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
  rm /tmp/inventory.docker /tmp/role.yml /tmp/first.log /tmp/second.log
done

ansible-playbook -i "$INVENTORY" --syntax-check playbooks/bootstrap.yml
ansible-playbook -i "$INVENTORY" --syntax-check playbooks/site.yml

CONTAINER_NAME=openwrt-test
docker run -d --rm --name "$CONTAINER_NAME" "$IMAGE" /sbin/init >/dev/null
docker exec "$CONTAINER_NAME" opkg update
docker exec "$CONTAINER_NAME" opkg install python3 cron
cat <<EOT >/tmp/inventory.docker
[openwrt]
$CONTAINER_NAME ansible_connection=community.docker.docker ansible_python_interpreter=/usr/bin/python3
[openwrt:vars]
backup_enabled=false
EOT
ansible-playbook -i /tmp/inventory.docker playbooks/bootstrap.yml
ansible-playbook -i /tmp/inventory.docker playbooks/site.yml
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
rm /tmp/inventory.docker
