# ADR 0010 - CI mono-environnement

Date: 2025-03-16

## Statut
Acceptée

## Contexte
La matrice multi-environnements introduite précédemment dans la CI exécutait les
tests sur `lab`, `staging` et `production`. Les inventaires `lab` et `staging`
ne sont cependant plus maintenus : leurs adresses IP ne correspondent à aucun
équipement et la documentation de test reposait sur `ENV=lab` tandis que le
Makefile utilisait `production` comme valeur par défaut. Cette divergence rendait
l'exécution locale incohérente et rallongeait la durée du pipeline GitHub
Actions sans bénéfice opérationnel.

## Décision
- Retirer les inventaires `lab` et `staging` du dépôt pour ne conserver que la
  cible `production`.
- Simplifier le workflow GitHub Actions pour exécuter `make test` et `make deploy`
  uniquement sur l'inventaire `production`.
- Mettre `scripts/test.sh` en cohérence avec le Makefile en utilisant `ENV=production`
  par défaut et en vérifiant la présence de l'inventaire ciblé.

## Conséquences
- Réduction du temps d'exécution global de la CI et suppression des jobs
  redondants.
- Le pipeline reflète exactement l'environnement réellement déployé, évitant les
  divergences de configuration.
- Les contributeurs doivent créer de nouveaux inventaires via Git lorsqu'un
  autre environnement est nécessaire, en documentant la décision au besoin.
