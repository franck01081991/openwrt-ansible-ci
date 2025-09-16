# ADR 0008 - Tests de conformité des rôles en conteneur

date: 2025-02-14

## Contexte
Seul le rôle `base` disposait d'un scénario Molecule et les autres rôles n'étaient pas vérifiés isolément. Cette situation exposait à des effets de bord lors des déploiements.

## Décision
Chaque rôle est désormais exécuté dans un conteneur OpenWrt éphémère pour vérifier son idempotence et sa conformité. L'outil Molecule est retiré au profit d'un script commun.

## Conséquences
- Couverture de tests homogène pour tous les rôles.
- Pipeline CI simplifiée et plus rapide.
- Réduction des dépendances (suppression de Molecule).
- Export des journaux d'exécution via des artéfacts GitHub Actions pour
  faciliter l'analyse des échecs.
- Nettoyage automatique du répertoire d'artéfacts pour éviter les journaux
  obsolètes ou des suppressions accidentelles.
- Annulation automatique des exécutions obsolètes via la concurrence GitHub
  Actions pour accélérer les retours développeur.
