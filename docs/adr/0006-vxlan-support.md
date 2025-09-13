# ADR 0006 - Support VXLAN

date: 2025-09-13

## Contexte
Le déploiement actuel ne permet pas de créer des réseaux superposés (overlay) pour relier facilement plusieurs sites ou segments isolés. Les tunnels existants exigent une configuration manuelle et ne tirent pas parti des fonctionnalités d'encapsulation modernes.

## Décision
Introduire la prise en charge de [VXLAN](https://datatracker.ietf.org/doc/html/rfc7348) dans l'infrastructure afin d'encapsuler le trafic de niveau 2 sur le réseau IP existant. Les rôles et playbooks devront permettre la création d'interfaces VXLAN paramétrables.

## Conséquences
- Possibilité de déployer des réseaux overlay extensibles sans dépendre de liaisons physiques dédiées.
- Configuration réseau plus complexe nécessitant une attention accrue lors du dépannage.
- Surcoût léger en termes de MTU et de consommation CPU dû à l'encapsulation.
