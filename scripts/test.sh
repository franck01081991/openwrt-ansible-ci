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
