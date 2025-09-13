# ADR 0001 - Gestion des secrets avec SOPS et age

date: 2025-09-13

## Contexte
Les variables sensibles doivent être chiffrées pour respecter l'approche GitOps.

## Décision
Utiliser [SOPS](https://github.com/getsops/sops) avec une clé publique [age](https://age-encryption.org/) pour chiffrer les fichiers `group_vars/*.sops.yml`. Les fichiers déchiffrés `group_vars/*.secrets.yml` sont ignorés par Git.

## Conséquences
- Édition sécurisée des secrets via `sops`.
- Distribution de la clé privée age aux opérateurs autorisés.
- Nécessité de conserver `sops.yaml` à jour en cas de rotation de clé.
