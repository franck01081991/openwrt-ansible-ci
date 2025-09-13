# Rôle firewall

Déploie la configuration `fw4` du pare-feu OpenWrt, incluant VLANs et WireGuard.

## Variables
- `firewall_wireguard` : interfaces WireGuard à autoriser.
- `firewall_vlans` : règles spécifiques pour les VLANs.

## Utilisation
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
