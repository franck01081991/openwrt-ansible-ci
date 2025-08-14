# OpenWrt Ansible – GitOps-friendly repo

Ce dépôt fournit une base **opinionated mais simple** pour gérer des routeurs **OpenWrt** avec **Ansible** et un workflow Git (GitHub/Gitea).

## TL;DR

```bash
# 1) Installer les collections
ansible-galaxy collection install -r requirements.yml

# 2) Bootstraper les routeurs (installe python3-light + sftp)
ansible-playbook -i inventories/production/hosts.ini playbooks/bootstrap.yml

# 3) Adapter vos variables dans group_vars et inventories/
$EDITOR group_vars/openwrt.yml inventories/production/hosts.ini

# 4) Appliquer la conf
ansible-playbook -i inventories/production/hosts.ini playbooks/site.yml
```

> ⚠️ OpenWrt n'embarque pas Python ni SFTP par défaut (Dropbear).  
> Le **bootstrap** utilise uniquement `raw` pour installer `python3-light` et `openssh-sftp-server`.  
> Après ça, vous profitez des modules Ansible (opkg, template, uci…).

## Arborescence

- `ansible.cfg` — réglages par défaut
- `requirements.yml` — collections Ansible (dont `community.general`)
- `inventories/production/hosts.ini` — inventaire d'exemple
- `group_vars/openwrt.yml` — variables communes
- `playbooks/bootstrap.yml` — prépare les cibles OpenWrt
- `playbooks/site.yml` — applique les rôles
- `roles/` — rôles idempotents (base, packages, network, firewall, dnsdhcp, wireless)

## Prérequis côté *control node*
- Ansible (ansible-core ≥ 2.14 recommandé)
- Accès SSH clé publique -> `root@routeur`
- Connexion IPv4/IPv6 vers les routeurs

## Notes
- **DSA/ports** : adaptez `network.bridge_ports` et `network.wan.device` selon votre matériel (ex: `lan1..lan4`, `wan`, `eth0`, etc.).
- **WiFi** : la configuration radio peut dépendre du SoC/driver. Le rôle `wireless` propose un *template* minimaliste (désactivé par défaut).
- **WireGuard** : variables prévues ; désactivé par défaut. Ajoutez vos clés et peers.


---

## CI GitHub Actions

Un workflow CI (`.github/workflows/ci.yml`) vérifie :
- `ansible-lint`
- `--syntax-check` sur `bootstrap.yml` et `site.yml` (inventaire production)

## Inventaires multi-sites

Répertoires fournis :
- `inventories/production/hosts.ini`
- `inventories/staging/hosts.ini`
- `inventories/lab/hosts.ini`

Tu peux sélectionner l'inventaire ainsi :
```bash
ansible-playbook -i inventories/lab/hosts.ini playbooks/site.yml
```

## VLAN / IoT

Active les VLANs dans `group_vars/openwrt.yml` :
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

Le template :
- crée `bridge-vlan` + interface `br-lan.<vid>`
- ajoute DHCP par VLAN si `iface.dhcp` est défini
- ajoute une zone `iot` (ou autre `name`) **vers WAN uniquement** si `restrict_to_internet: true`

## ImageBuilder

Un helper `imagebuilder/build.sh` permet de générer des images OpenWrt intégrant
les paquets nécessaires à Ansible (ex: `python3-light`, `openssh-sftp-server`).

Exemple :
```bash
cd imagebuilder
./build.sh --release 24.10.0 --target ramips --subtarget mt7621 --profile xiaomi_mi-router-4a-gigabit
```
