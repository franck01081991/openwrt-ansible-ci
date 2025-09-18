# ADR 0009 - Couverture CI multi-environnements

Date: 2025-03-15

## Statut
Superseded par [ADR 0010 - CI mono-environnement](./0010-ci-single-environment.md)

## Notes
Cette décision a été remplacée le 2025-03-16 afin de revenir à un pipeline
centré sur l'inventaire `production`.

## Contexte
La suite de tests de la CI n'était exécutée que sur l'inventaire `lab`. Les
inventaires `staging` et `production` disposent pourtant de paramètres
spécifiques (adresses IP, options réseaux) susceptibles de révéler des
régressions non détectées avec un seul environnement. Les contributions
récentes ont également introduit un job `lint` dédié : rejouer l'ensemble du
pipeline pour chaque inventaire aurait entraîné des redondances inutiles.

## Décision
- Introduire un job `test` avec une matrice GitHub Actions couvrant les trois
  inventaires (`lab`, `staging`, `production`).
- Injecter la variable `ENV=${{ matrix.env }}` avant `make test` afin d'exécuter
  les scénarios sur l'inventaire ciblé.
- Conserver un job `lint` distinct qui prépare l'environnement (caches pip,
  collections Ansible) et exécute les contrôles statiques, en amont du job de
  tests.

## Conséquences
- Détection plus précoce des divergences entre inventaires.
- Allongement modéré du temps global du pipeline, compensé par l'absence de
  ré-exécution des linters pour chaque environnement.
- Les caches partagés par GitHub Actions doivent être conservés dans les deux
  jobs (`lint` et `test`) pour limiter les téléchargements répétés.
