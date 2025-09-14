.RECIPEPREFIX := >
SHELL := /bin/bash

ENV ?= production
PLAYBOOK ?= playbooks/site.yml
INVENTORY ?= inventories/$(ENV)/hosts.yml

.PHONY: install lint test scan site bootstrap deploy

install:
>python -m pip install --upgrade pip
>pip install "ansible-core>=2.14,<2.17" ansible-lint yamllint pre-commit docker
>ansible-galaxy collection install -r requirements.yml
>curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
>pre-commit install --install-hooks -t pre-commit -t commit-msg

lint:
>pre-commit run --all-files

test:
>ENV=$(ENV) ./scripts/test.sh

site:
>ansible-playbook -i $(INVENTORY) playbooks/site.yml

bootstrap:
>ansible-playbook -i $(INVENTORY) playbooks/bootstrap.yml

deploy:
>ansible-playbook -i $(INVENTORY) $(PLAYBOOK)

scan:
>trivy fs --exit-code 1 --security-checks vuln,config,secret --ignore-unfixed --severity CRITICAL,HIGH .
