# OpenWrt Ansible

Ce dépôt fournit une collection de rôles Ansible et de playbooks pour gérer des routeurs **OpenWrt** selon des principes **GitOps**. Toutes les modifications passent par Git et peuvent être auditées.

## Prérequis
- Linux ou macOS avec Git, Python ≥3.11 et ansible-core ≥2.14
- Accès SSH par clé publique vers `root@routeur`
- Connexion IPv4/IPv6 vers les équipements
- Paquets supplémentaires installés sur le routeur : `python3-light` et `openssh-sftp-server` (via `playbooks/bootstrap.yml`)

## Installation rapide
1. Cloner le dépôt et installer les collections :
   ```bash
   git clone https://example.com/openwrt-ansible-ci.git
   cd openwrt-ansible-ci
   ansible-galaxy collection install -r requirements.yml
   ```
2. Enregistrer la clé hôte et lancer le bootstrap :
   ```bash
   ssh-keyscan -H routeur >> ~/.ssh/known_hosts
   ansible-playbook -i inventories/production/hosts.ini playbooks/bootstrap.yml
   ```
3. Adapter l’inventaire et les variables :
   ```bash
   $EDITOR inventories/production/hosts.ini group_vars/openwrt.yml
   ```
4. Appliquer la configuration :
   ```bash
   ansible-playbook -i inventories/production/hosts.ini playbooks/site.yml
   ```

## Développement
Ce dépôt utilise [pre-commit](https://pre-commit.com) pour exécuter les linters
(`yamllint`, `ansible-lint`, `shellcheck`) et vérifier le style des fichiers.
Pour préparer l'environnement local :

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

Les hooks sont également exécutés dans la CI.

## Gestion des secrets
Ce dépôt utilise [SOPS](https://github.com/getsops/sops) avec des clés [age](https://age-encryption.org/) pour chiffrer les variables sensibles.

Pour éditer un fichier chiffré :
```bash
sops group_vars/example.sops.yml
```

Le fichier déchiffré `group_vars/*.secrets.yml` est ignoré par Git.


## Inventaires
Trois environnements sont fournis :

| Inventaire  | Usage           |
|-------------|-----------------|
| `lab`       | tests locaux    |
| `staging`   | préproduction   |
| `production`| déploiement     |

Sélectionner l’inventaire avec `-i` :

```bash
ansible-playbook -i inventories/lab/hosts.ini playbooks/site.yml
```

## Structure du dépôt
```text
ansible.cfg                 # paramètres Ansible
requirements.yml            # collections
inventories/                # inventaires lab/staging/production
group_vars/                 # variables partagées
playbooks/                  # bootstrap + site
roles/                      # rôles Ansible
docs/                       # documentation
imagebuilder/               # génération d’images personnalisées
```

## Rôles disponibles
- [base](roles/base/README.md) : système de base (hostname, timezone, clés SSH)
- [packages](roles/packages/README.md) : installation de paquets
- [ntp](roles/ntp/README.md) : synchronisation horaire
- [logging](roles/logging/README.md) : redirection des journaux
- [ids](roles/ids/README.md) : détection d’intrusion Suricata
- [backup](roles/backup/README.md) : sauvegardes programmées
- [fail2ban](roles/fail2ban/README.md) : protection par bannissement
- [ha](roles/ha/README.md) : haute disponibilité VRRP
- [network](roles/network/README.md) : interfaces, VLANs, WireGuard
- [dnsdhcp](roles/dnsdhcp/README.md) : service DNS/DHCP
- [routing](roles/routing/README.md) : routage dynamique Bird2
- [wireless](roles/wireless/README.md) : configuration Wi-Fi
- [firewall](roles/firewall/README.md) : règles pare-feu supplémentaires
- [monitoring](roles/monitoring/README.md) : métriques collectd

## Documentation
- [Guide de déploiement](docs/deploiement-openwrt.md)
- [Exemples d’utilisation](docs/examples.md)
- [ImageBuilder](imagebuilder/README.md)

## Licence
Ce projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).
