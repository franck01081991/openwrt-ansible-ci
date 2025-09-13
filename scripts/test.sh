#!/bin/bash
set -e
for role in roles/*; do
  if [ -d "$role/molecule" ]; then
    (cd "$role" && molecule test)
  fi
done
ansible-playbook -i inventories/production/hosts.ini --syntax-check playbooks/bootstrap.yml
ansible-playbook -i inventories/production/hosts.ini --syntax-check playbooks/site.yml
