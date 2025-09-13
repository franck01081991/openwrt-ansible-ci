# ADR 0005 - Inventaires Ansible en YAML

date: 2025-02-14

## Contexte
Les inventaires étaient auparavant au format INI (`hosts.ini`) et l'inventaire de production était fixé par défaut dans `ansible.cfg`.

## Décision
Adopter le format YAML (`hosts.yml`) pour tous les inventaires et supprimer toute référence à un inventaire par défaut dans `ansible.cfg`. L'inventaire est désormais choisi explicitement via l'option `-i` ou la variable `INVENTORY` du `Makefile`.

## Conséquences
- Inventaires plus structurés et extensibles.
- Obligation de spécifier l'inventaire lors de l'exécution des playbooks, évitant les erreurs de contexte.
- Mise à jour de la documentation, des tests et des scripts pour refléter le nouveau format.
