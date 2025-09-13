.RECIPEPREFIX := >
SHELL := /bin/bash

.PHONY: install lint test scan

install:
>python -m pip install --upgrade pip
>pip install "ansible-core>=2.14,<2.17" ansible-lint yamllint pre-commit molecule molecule-plugins
>ansible-galaxy collection install -r requirements.yml
>curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
>pre-commit install --install-hooks -t pre-commit -t commit-msg

lint:
>pre-commit run --all-files

test:
>./scripts/test.sh

scan:
>trivy fs --exit-code 1 --security-checks vuln,config,secret --ignore-unfixed --severity CRITICAL,HIGH .
