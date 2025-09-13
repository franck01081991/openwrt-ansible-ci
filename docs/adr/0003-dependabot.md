# ADR 0003 - Automatisation des mises à jour avec Dependabot

date: 2025-09-15

## Contexte
Les dépendances des workflows et outils peuvent rapidement devenir obsolètes et comporter des vulnérabilités.

## Décision
Activer [Dependabot](https://docs.github.com/fr/code-security/dependabot) pour vérifier et proposer automatiquement les mises à jour des actions GitHub.

## Conséquences
- Un fichier `.github/dependabot.yml` configure une vérification hebdomadaire.
- Des Pull Requests automatiques seront ouvertes pour maintenir les actions à jour.
- Les mainteneurs doivent examiner et fusionner ces mises à jour.
