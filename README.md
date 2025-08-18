# OpenWrt Ansible – GitOps-friendly repo

## Description du projet et objectifs
Ce projet fournit une base simple pour administrer des routeurs **OpenWrt** avec **Ansible** en adoptant une approche GitOps. L'objectif est de déployer une configuration cohérente, versionnée et facile à reproduire.

## Prérequis pour le poste de contrôle
- Linux ou macOS avec accès à Internet
- Ansible (ansible-core ≥ 2.14)
- Python 3 et `pip`
- Accès SSH par clé publique vers `root@routeur`
- Connectivité IPv4/IPv6 vers les routeurs

## Installation et configuration
1. Cloner ce dépôt :
```bash
git clone https://example.com/openwrt-ansible-ci-vlan-imagebuilder.git
cd openwrt-ansible-ci-vlan-imagebuilder
```
2. Installer les collections Ansible :
```bash
ansible-galaxy collection install -r requirements.yml
```
3. Si c'est la première connexion, enregistrer la clé hôte du routeur :
```bash
ssh-keyscan -H routeur >> ~/.ssh/known_hosts
# ou établir une connexion SSH initiale :
# ssh root@routeur
```
4. Bootstrap des routeurs (installe `python3-light` et `openssh-sftp-server`) :
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

## Inventaires `lab` et `staging`

Outre `production`, deux inventaires supplémentaires sont fournis :

- **lab** : pour les tests et expérimentations.
- **staging** : pour la préproduction avant déploiement.

Sélectionnez l'inventaire voulu avec l'option `-i` :

```bash
# Exemple d'exécution sur l'inventaire de test
ansible-playbook -i inventories/lab/hosts.ini playbooks/site.yml

# Exemple d'exécution sur l'inventaire de préproduction
ansible-playbook -i inventories/staging/hosts.ini playbooks/site.yml
```

## Arborescence et rôles
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
  bootstrap.yml             # Prépare les cibles (python + sftp)
  site.yml                  # Applique les rôles
roles/
  base/                     # Configuration de base
  packages/                 # Paquets supplémentaires
  ntp/                      # Synchronisation du temps
  logging/                 # Redirection des logs
  backup/                  # Sauvegarde de la configuration
  fail2ban/                 # Protection fail2ban
  ha/                       # Haute disponibilité VRRP
  network/                  # Interfaces, VLANs, firewall
  dnsdhcp/                  # DNS et DHCP
  routing/                  # Routage dynamique
  wireless/                 # WiFi
```

## Valeurs par défaut des rôles
Chaque rôle inclut des variables préfixées dans `defaults/main.yml` :

- **base** (`base_system`) : nom d'hôte `openwrt`, fuseau `UTC`, serveurs NTP standards.
- **packages** (`packages_opkg_packages`) : openssh-sftp-server, ca-bundle, ca-certificates, luci-ssl, htop, rsyslog, fail2ban, bird2, keepalived.
- **ntp** (`ntp_enabled`, `ntp_servers`) : installe le démon NTP et définit les sources de temps utilisées par le routeur et ses clients.
- **logging** (`logging_enabled`, `logging_server`, `logging_facility`) : désactivé par défaut, redirige les logs vers `logging_server` avec la facility `logging_facility`
- **backup** (`backup_enabled`, `backup_destination`, `backup_schedule`) : archive `/etc/config` et fichiers critiques vers `backup_destination` selon `backup_schedule`.
- **fail2ban** (`fail2ban_enabled`, `fail2ban_jails`) : service activé avec jails SSH et LuCI.
- **ha** (`ha_enabled`, `ha_vrrp_instances`) : désactivé par défaut, déploie keepalived et les instances VRRP.
- **network** (`network_config`) : LAN `192.168.1.1/24` sur `br-lan`, WAN DHCP sur `wan`, ports `lan1..lan4`. `network_wireguard.enabled` et `network_vlans.enabled` désactivés.
- **dnsdhcp** (`dnsdhcp_config.lan_dhcp`) : début `100`, limite `150`, bail `12h`, domaine `lan`.
- **routing** (`routing_enabled`, `routing_protocol`, `routing_config`) : désactivé par défaut, protocole `bird2`.
- **wireless** (`wireless_config`) : désactivé par défaut, SSID `MyWiFi`, chiffrement `psk2`.
- **firewall** : aucune zone supplémentaire ; s'appuie sur `firewall_wireguard`/`firewall_vlans`.

### Exemple logging

```yaml
logging_enabled: true
logging_server: log.example.com
logging_facility: '*'
```

### Exemple fail2ban

```yaml
fail2ban_enabled: true
fail2ban_jails:
  - name: ssh
    port: ssh
    logpath: /var/log/auth.log
  - name: luci
    port: http,https
    logpath: /var/log/uhttpd-access.log
```

### Exemple monitoring

```yaml
monitoring_enabled: true
monitoring_plugins:
  - cpu
  - interface
  - memory
```

Ajoutez de nouveaux plugins en les listant dans `monitoring_plugins`. Pour envoyer les métriques vers un collecteur distant, incluez le plugin `network` et configurez la section `Server` du template `collectd.conf.j2`.

### Exemple NTP

```yaml
ntp_enabled: true
ntp_servers:
  - 0.pool.ntp.org
  - 1.pool.ntp.org
```

Le rôle installe le démon `ntpd` qui synchronise l'horloge du routeur auprès de ces sources et peut servir de référence pour les clients du réseau.

## Exemple VLAN / IoT
Activer un VLAN isolé pour les objets connectés :
```yaml
network_vlans: &iot_vlan
  enabled: true
  list:
    - id: 20
      name: "iot"
      device: "br-lan"
      ports: ["lan2:u*", "lan3:t", "lan4:t"]
      iface:
        name: "iot"
        address: "192.168.20.1"
        netmask: "255.255.255.0"
        dhcp: { start: 50, limit: 100, leasetime: "12h" }
      firewall:
        restrict_to_internet: true
dnsdhcp_vlans: *iot_vlan
firewall_vlans: *iot_vlan
```
Ce template :
- crée `bridge-vlan` et l'interface `br-lan.<vid>`
- ajoute un DHCP si `iface.dhcp` est défini
- crée une zone `iot` vers Internet uniquement si `restrict_to_internet: true`

## Exemple Bird2
Activer le routage dynamique avec Bird2 :
```yaml
routing_enabled: true
routing_protocol: bird2
routing_config: |
  router id 192.0.2.1;

  protocol device {}
  protocol direct {
    interface "*";
  }

# Déclarer des interfaces supplémentaires si besoin
routing_interfaces:
  - name: wan2
    proto: dhcp
    device: eth1
```

## Exemple Haute disponibilité
Activer une adresse virtuelle partagée entre deux routeurs :
```yaml
ha_enabled: true
ha_vrrp_instances:
  - name: VI_LAN
    state: MASTER
    interface: br-lan
    priority: 101
    virtual_ip: 192.168.10.254
```
Pour provoquer une bascule, arrêter le service sur le maître :
```bash
ssh root@routeur1 /etc/init.d/keepalived stop
```
Le routeur secondaire adopte l'adresse virtuelle. Relancer le service pour revenir à l'état initial :
```bash
ssh root@routeur1 /etc/init.d/keepalived start
```

## Exemple ImageBuilder
Générer une image OpenWrt contenant les paquets utiles à Ansible :
```bash
cd imagebuilder
./build.sh --release 24.10.0 --target ramips --subtarget mt7621 --profile xiaomi_mi-router-4a-gigabit
```

## CI
Le workflow GitHub Actions `.github/workflows/ci.yml` vérifie :
- `ansible-lint`
- `ansible-playbook --syntax-check` sur `playbooks/bootstrap.yml` et `playbooks/site.yml`

### Restauration depuis une archive

```bash
scp backup.tgz root@routeur:/tmp/
ssh root@routeur "tar xzf /tmp/backup.tgz -C /"
```

## Secrets chiffrés avec SOPS

Les secrets (ex. clés WireGuard) résident dans `group_vars/*.sops.yaml` et sont chiffrés avec [SOPS](https://github.com/getsops/sops) et `age`.
Pour les éditer, exporter la clé privée et utiliser `sops` :

```bash
export SOPS_AGE_KEY_FILE=agekey.txt
sops group_vars/wireguard-secrets.sops.yaml
```

## Notes
- **Ports DSA** : ajustez `network_config.bridge_ports` et `network_config.wan.device` selon votre matériel (`lan1..lan4`, `wan`, etc.).
- **WiFi** : le rôle `wireless` propose un template minimaliste désactivé par défaut (`wireless_config`).
- **WireGuard** : variables `network_wireguard`/`firewall_wireguard` prévues mais désactivées ; renseignez vos clés et peers.

## Licence
Ce projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).
