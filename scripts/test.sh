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
  cat <<EOT >/tmp/inventory.docker
[openwrt]
$CONTAINER_NAME ansible_connection=community.docker.docker
[openwrt:vars]
backup_enabled=false
EOT
  cat <<EOT >/tmp/role.yml
- hosts: openwrt
  gather_facts: false
  roles:
    - $role_name
EOT
  ansible-playbook -i /tmp/inventory.docker /tmp/role.yml >/tmp/first.log
  second_run=$(ansible-playbook -i /tmp/inventory.docker /tmp/role.yml)
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
cat <<EOT >/tmp/inventory.docker
[openwrt]
$CONTAINER_NAME ansible_connection=community.docker.docker
[openwrt:vars]
backup_enabled=false
EOT
ansible-playbook -i /tmp/inventory.docker playbooks/bootstrap.yml
ansible-playbook -i /tmp/inventory.docker playbooks/site.yml
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
rm /tmp/inventory.docker
