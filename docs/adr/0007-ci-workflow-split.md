# ADR 0007 - Séparation des workflows CI selon les types de fichiers

date: 2025-02-14

## Contexte
Un seul workflow CI exécutait l'ensemble des linters et tests pour toute
modification, même lorsque seuls des fichiers de documentation étaient
ajoutés ou modifiés. Cela rallongeait inutilement la durée des pipelines et
les retours de revue.

## Décision
Mettre en place un workflow spécifique `Docs CI` déclenché uniquement pour
les fichiers Markdown et le dossier `docs/`. Le workflow principal est
restreint aux chemins liés à la configuration Ansible et aux scripts grâce
au paramètre `paths`. Chaque workflow exécute les tâches adaptées au type de
modification.

## Conséquences
- Les contributions de documentation déclenchent un pipeline léger avec les
  vérifications Markdown et commitlint.
- Les modifications de configuration conservent le pipeline complet avec
  linters, tests et déploiement.
- La séparation des workflows réduit le temps de traitement des Merge
  Requests et facilite leur revue.
