# OpenWrt Ansible

Ce dépôt facilite l'administration de routeurs **OpenWrt** avec **Ansible** dans une approche GitOps. Il fournit des rôles et playbooks réutilisables pour déployer une configuration cohérente et versionnée.

## Table des matières
1. [Prérequis](#prérequis)
2. [Installation rapide](#installation-rapide)
3. [Inventaires](#inventaires)
4. [Structure du dépôt](#structure-du-dépôt)
5. [Rôles disponibles](#rôles-disponibles)
6. [Documentation complémentaire](#documentation-complémentaire)
7. [Licence](#licence)

## Prérequis
- Linux ou macOS avec accès à Internet
- Ansible (ansible-core \u2265 2.14)
- Python 3 et `pip`
- Accès SSH par clé publique vers `root@routeur`
- Connectivité IPv4/IPv6 vers les routeurs

## Installation rapide
1. Cloner ce dépôt :
   ```bash
   git clone https://example.com/openwrt-ansible-ci-vlan-imagebuilder.git
   cd openwrt-ansible-ci-vlan-imagebuilder
   ```
2. Installer les collections Ansible :
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```
3. Enregistrer la clé hôte du routeur si nécessaire :
   ```bash
   ssh-keyscan -H routeur >> ~/.ssh/known_hosts
   # ou établir une connexion SSH initiale
   # ssh root@routeur
   ```
4. Préparer les routeurs (installe `python3-light` et `openssh-sftp-server`) :
   ```bash
   ansible-playbook -i inventories/production/hosts.ini playbooks/bootstrap.yml
   ```
5. Adapter les variables :
   ```bash
   $EDITOR group_vars/openwrt.yml inventories/production/hosts.ini
   ```
6. Appliquer la configuration :
   ```bash
   ansible-playbook -i inventories/production/hosts.ini playbooks/site.yml
   ```

## Inventaires
Trois inventaires sont fournis :
- **lab** : tests et expérimentations
- **staging** : préproduction
- **production** : déploiement

Sélectionnez l'inventaire voulu avec l'option `-i` :
```bash
ansible-playbook -i inventories/lab/hosts.ini playbooks/site.yml
```

## Structure du dépôt
```text
ansible.cfg                 # Réglages par défaut
requirements.yml            # Collections Ansible
inventories/
  lab/hosts.ini             # Inventaire de test
  staging/hosts.ini         # Inventaire de préproduction
  production/hosts.ini      # Inventaire d'exemple
group_vars/
  openwrt.yml               # Variables communes
playbooks/
  bootstrap.yml             # Prépare les cibles
  site.yml                  # Applique les rôles
roles/                      # Rôles Ansible
```

## Rôles disponibles
- base : configuration de base
- packages : paquets supplémentaires
- ntp : synchronisation du temps
- logging : redirection des logs
- ids : intrusion detection (Suricata)
- backup : sauvegarde de la configuration
- fail2ban : protection fail2ban
- ha : haute disponibilité VRRP
- network : interfaces, VLANs, firewall
- dnsdhcp : DNS et DHCP
- routing : routage dynamique
- wireless : WiFi
- firewall : règles additionnelles

## Documentation complémentaire
- [Tutoriel détaillé](docs/deploiement-openwrt.md)
- [Exemples de configuration](docs/examples.md)

## Licence
Ce projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).
