# Rôle firewall

## Objectif
Déploie la configuration `fw4` du pare‑feu OpenWrt, VLANs et WireGuard inclus.

## Variables
- `firewall_wireguard` (dict) : interfaces WireGuard à autoriser
- `firewall_vlans` (dict) : règles spécifiques pour les VLANs

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: firewall
      vars:
        firewall_wireguard:
          enabled: true
          interfaces:
            - wg0
```
