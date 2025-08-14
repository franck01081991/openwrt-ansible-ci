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
3. Bootstrap des routeurs (installe `python3-light` et `openssh-sftp-server`) :
```bash
ansible-playbook -i inventories/production/hosts.ini playbooks/bootstrap.yml
```
4. Adapter les variables :
```bash
$EDITOR group_vars/openwrt.yml inventories/production/hosts.ini
```
5. Appliquer la configuration :
```bash
ansible-playbook -i inventories/production/hosts.ini playbooks/site.yml
```

## Arborescence et rôles
```text
ansible.cfg                 # Réglages par défaut
requirements.yml            # Collections Ansible
inventories/
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
Chaque rôle inclut des variables par défaut dans `defaults/main.yml` :

- **base** (`system`) : nom d'hôte `openwrt`, fuseau `UTC`, serveurs NTP standards.
- **packages** (`opkg_packages`) : openssh-sftp-server, ca-bundle, ca-certificates, luci-ssl, htop.
- **network** (`network`) : LAN `192.168.1.1/24` sur `br-lan`, WAN DHCP sur `wan`, ports `lan1..lan4`. `wireguard.enabled` et `vlans.enabled` désactivés.
- **dnsdhcp** (`dnsdhcp.lan_dhcp`) : début `100`, limite `150`, bail `12h`, domaine `lan`.
- **wireless** (`wireless`) : désactivé par défaut, SSID `MyWiFi`, chiffrement `psk2`.
- **firewall** : aucune zone supplémentaire ; s'appuie sur les mêmes defaults `wireguard`/`vlans`.

## Exemple VLAN / IoT
Activer un VLAN isolé pour les objets connectés :
```yaml
vlans:
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
- **Ports DSA** : ajustez `network.bridge_ports` et `network.wan.device` selon votre matériel (`lan1..lan4`, `wan`, etc.).
- **WiFi** : le rôle `wireless` propose un template minimaliste désactivé par défaut.
- **WireGuard** : variables prévues mais désactivées ; renseignez vos clés et peers.

## Licence
Ce projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).
