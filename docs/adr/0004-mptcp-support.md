# ADR 0004 - Support Multipath TCP

date: 2025-09-16

## Contexte
Certaines applications bénéficient de connexions TCP multipath pour la redondance et l'agrégation de bande passante.

## Décision
Ajouter un rôle Ansible `mptcp` installant `kmod-mptcp` et `mptcpd`, activant `net.mptcp.enabled` et démarrant le service.

## Conséquences
- Possibilité d'activer MPTCP via la variable `mptcp_config`.
- Augmentation légère de la consommation mémoire.
- Nécessité de surveiller la compatibilité des paquets avec MPTCP.
