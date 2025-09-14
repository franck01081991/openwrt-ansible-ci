# ADR 0008 - Sélection des workflows CI selon le type de commit

date: 2025-09-14

## Contexte
Le workflow précédent (ADR 0007) séparait les pipelines en fonction des fichiers modifiés via `paths`. Cela ne permettait pas de baser la CI sur les types de commits selon la convention Conventional Commits.

## Décision
Les workflows GitHub Actions sont déclenchés pour chaque push ou pull request mais les jobs s'exécutent selon le préfixe du commit ou du titre (`docs:` pour la documentation). Un commit `docs:` n'exécute que le workflow `Docs CI`, tandis que les autres déclenchent le pipeline Ansible complet.

## Conséquences
- Simplifie la gestion : la séparation repose sur le type de commit plutôt que sur les chemins.
- Évite l'exécution de la pipeline principale pour les modifications de documentation.
- Nécessite le respect strict de Conventional Commits pour que le routage fonctionne.
