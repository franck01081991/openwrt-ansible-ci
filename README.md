# OpenWrt Ansible

Ce dépôt fournit une collection de rôles Ansible et de playbooks pour gérer des
routeurs **OpenWrt** selon des principes **GitOps**.
Toutes les modifications passent par Git et peuvent être auditées.

## Prérequis

- Linux ou macOS avec Git, Python ≥3.11 et ansible-core ≥2.14
- Accès SSH par clé publique vers `root@routeur`
- Connexion IPv4/IPv6 vers les équipements
- Paquets supplémentaires installés sur le routeur : `python3` et
  `openssh-sftp-server` (via `playbooks/bootstrap.yml`)

## Installation rapide

1. Cloner le dépôt et installer les collections :

   ```bash
   git clone https://example.com/openwrt-ansible-ci.git
   cd openwrt-ansible-ci
   ansible-galaxy collection install -r requirements.yml
   ```

2. Enregistrer la clé hôte et lancer le bootstrap :

   ```bash
   ssh-keyscan -H routeur >> ~/.ssh/known_hosts
   make deploy PLAYBOOK=playbooks/bootstrap.yml
   ```

3. Adapter l’inventaire et les variables :

   ```bash
   $EDITOR inventories/production/hosts.yml group_vars/openwrt.yml
   ```

4. Appliquer la configuration :

   ```bash
   make deploy ENV=production
   ```

## Développement

Ce dépôt utilise [pre-commit](https://pre-commit.com) pour exécuter les linters
(`yamllint`, `ansible-lint`, `shellcheck`) et vérifier le style des fichiers.
Des scénarios [Molecule](https://molecule.readthedocs.io) permettent de
tester les rôles Ansible localement et sont exécutés dans la CI.
Les messages de commit doivent suivre la convention
[Conventional Commits](https://www.conventionalcommits.org) et sont vérifiés via
[commitlint](https://commitlint.js.org) (`commitlint.config.js`).
Le hook `commit-msg` fourni par `pre-commit` applique cette vérification
localement ;
`make install` installe automatiquement les hooks nécessaires.

### Commandes Make

Les cibles utilisent l'inventaire déterminé par la variable `ENV` (défaut : `production`).
`PLAYBOOK` permet de choisir le playbook à exécuter (défaut : `playbooks/site.yml`).

Préparer l'environnement local et installer les hooks `pre-commit` :

```bash
make install
```

Exécuter les linters :

```bash
make lint
```

Lancer les tests Molecule et la vérification de syntaxe :

```bash
make test ENV=lab
```

Cette commande démarre un conteneur OpenWrt éphémère et applique les
playbooks pour valider chaque changement de configuration.

Déployer la configuration :

```bash
make deploy ENV=production
```

Bootstraper un routeur :

```bash
make deploy ENV=production PLAYBOOK=playbooks/bootstrap.yml
```

Scanner le dépôt :

```bash
make scan
```

Les hooks et tests sont également exécutés dans la CI.
Les tests s'exécutent pour chaque inventaire (`lab`, `staging`, `production`)
via une matrice d'environnement.
Sur `main`, un job de déploiement exécute `make deploy` pour chaque environnement.
Le pipeline GitHub Actions met en cache
`~/.cache/pip` et `~/.ansible` en fonction de
`requirements.yml` et `.pre-commit-config.yaml` afin de réduire les téléchargements
sur les exécutions ultérieures.

La sécurité est contrôlée via
[Trivy](https://github.com/aquasecurity/trivy) qui analyse le dépôt pour détecter
vulnérabilités, erreurs de configuration et secrets.
Un scan local peut être lancé avec `make scan`.

Les dépendances des workflows sont automatiquement mises à jour par
[Dependabot](https://docs.github.com/fr/code-security/dependabot).

## Gestion des secrets

Ce dépôt utilise [SOPS](https://github.com/getsops/sops) avec des clés
[age](https://age-encryption.org/) pour chiffrer
les variables sensibles.

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

Sélectionner l’inventaire avec `-i` ou via la variable `ENV` du Makefile :

```bash
ansible-playbook -i inventories/lab/hosts.yml playbooks/site.yml
# ou
make deploy ENV=lab
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
- [mptcp](roles/mptcp/README.md) : support Multipath TCP
- [wireless](roles/wireless/README.md) : configuration Wi-Fi
- [firewall](roles/firewall/README.md) : règles pare-feu supplémentaires
- [monitoring](roles/monitoring/README.md) : métriques collectd

## Documentation

- [Guide de déploiement](docs/deploiement-openwrt.md)
- [Exemples d’utilisation](docs/examples.md)
- [ImageBuilder](imagebuilder/README.md)
- [ADR 0006 - Support VXLAN](docs/adr/0006-vxlan-support.md)

## Licence

Ce projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).
