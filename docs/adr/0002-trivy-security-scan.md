# ADR 0002 - Analyse de sécurité avec Trivy

date: 2025-09-13

## Contexte
Pour garantir la qualité des infrastructures gérées via Ansible, il est nécessaire de détecter les vulnérabilités dans les dépendances et configurations.

## Décision
Utiliser [Trivy](https://github.com/aquasecurity/trivy) pour scanner le dépôt. Les scans sont exécutés localement via un hook pre-commit et dans la CI avec `aquasecurity/trivy-action`.
Le seuil de sévérité est fixé à `HIGH,CRITICAL` et les vulnérabilités non corrigées sont ignorées (`--ignore-unfixed`).

## Conséquences
- Visibilité précoce sur les failles de sécurité.
- Échecs de commit ou de pipeline si des vulnérabilités critiques sont détectées.
- Possibilité d'ajuster la politique en modifiant `.pre-commit-config.yaml` et le workflow CI.
