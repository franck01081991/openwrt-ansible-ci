#!/bin/bash
set -e

ENV=${ENV:-production}
INVENTORY="inventories/${ENV}/hosts.yml"

for role in roles/*; do
  if [ -d "$role/molecule" ]; then
    (cd "$role" && molecule test)
  fi
done

ansible-playbook -i "$INVENTORY" --syntax-check playbooks/bootstrap.yml
ansible-playbook -i "$INVENTORY" --syntax-check playbooks/site.yml

# Run configuration against an ephemeral OpenWrt container
CONTAINER_NAME=openwrt-test
IMAGE=${OPENWRT_IMAGE:-openwrt/rootfs:x86_64-23.05.6}

docker run -d --rm --name "$CONTAINER_NAME" "$IMAGE" /sbin/init >/dev/null
trap 'docker rm -f $CONTAINER_NAME >/dev/null 2>&1' EXIT

cat <<EOF > /tmp/inventory.docker
[openwrt]
$CONTAINER_NAME ansible_connection=community.docker.docker
EOF

ansible-playbook -i /tmp/inventory.docker playbooks/bootstrap.yml
ansible-playbook -i /tmp/inventory.docker playbooks/site.yml

rm /tmp/inventory.docker
