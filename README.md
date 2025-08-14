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
  network/                  # Interfaces, VLANs, firewall
  dnsdhcp/                  # DNS et DHCP
  wireless/                 # WiFi
```

## Valeurs par défaut des rôles
Chaque rôle inclut des variables préfixées dans `defaults/main.yml` :

- **base** (`base_system`) : nom d'hôte `openwrt`, fuseau `UTC`, serveurs NTP standards.
- **packages** (`packages_opkg_packages`) : openssh-sftp-server, ca-bundle, ca-certificates, luci-ssl, htop.
- **network** (`network_config`) : LAN `192.168.1.1/24` sur `br-lan`, WAN DHCP sur `wan`, ports `lan1..lan4`. `network_wireguard.enabled` et `network_vlans.enabled` désactivés.
- **dnsdhcp** (`dnsdhcp_config.lan_dhcp`) : début `100`, limite `150`, bail `12h`, domaine `lan`.
- **wireless** (`wireless_config`) : désactivé par défaut, SSID `MyWiFi`, chiffrement `psk2`.
- **firewall** : aucune zone supplémentaire ; s'appuie sur `firewall_wireguard`/`firewall_vlans`.

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

## Notes
- **Ports DSA** : ajustez `network_config.bridge_ports` et `network_config.wan.device` selon votre matériel (`lan1..lan4`, `wan`, etc.).
- **WiFi** : le rôle `wireless` propose un template minimaliste désactivé par défaut (`wireless_config`).
- **WireGuard** : variables `network_wireguard`/`firewall_wireguard` prévues mais désactivées ; renseignez vos clés et peers.

## Licence
Ce projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).
