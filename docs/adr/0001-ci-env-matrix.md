# ADR 0001: Exécuter les tests CI sur plusieurs inventaires

Date: 2024-05-07

## Statut
Acceptée

## Contexte
Les tests de la CI ne couvraient qu'un seul inventaire, limitant la validation des environnements.

## Décision
Utiliser une matrice d'environnements (`lab`, `staging`, `production`) dans le workflow GitHub Actions.
Chaque exécution définit `ENV` en conséquence via `ENV=${{ matrix.env }} make test` afin de lancer les tests pour l'inventaire ciblé.

## Conséquences
Les tests s'exécutent pour chaque inventaire, augmentant le temps d'exécution mais assurant une validation complète.
