# ADR 0002 - Intégration de Trivy pour l'analyse de sécurité

date: 2025-09-14

## Contexte
Afin de renforcer la sécurité dans l'approche GitOps, il est nécessaire d'analyser automatiquement le dépôt pour détecter les vulnérabilités, les erreurs de configuration et les secrets accidentellement commis.

## Décision
Utiliser [Trivy](https://github.com/aquasecurity/trivy) pour scanner le dépôt dans la CI.

## Conséquences
- Un scan Trivy est exécuté à chaque pipeline GitHub Actions.
- Les développeurs peuvent lancer `trivy fs .` localement pour vérifier leurs changements.
- La version de Trivy utilisée dans le pipeline doit être maintenue à jour.
