# ADR 0002 - Tests des rôles avec Molecule

date: 2024-05-21

## Contexte
La validation automatique des rôles est nécessaire pour garantir leur bon fonctionnement et faciliter les contributions.

## Décision
Adopter [Molecule](https://molecule.readthedocs.io/) avec le pilote Docker pour tester les rôles Ansible. Un scénario initial est ajouté pour le rôle `base` et intégré à la CI.

## Conséquences
- Dépendance supplémentaire `molecule[docker]`.
- Exécution de `molecule test` dans la CI sur chaque pull request.
- Les contributeurs peuvent vérifier les rôles localement avant soumission.
