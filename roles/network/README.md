# Rôle network

Gère la configuration des interfaces réseau, VLANs et tunnels WireGuard.

## Variables
- `network_config` : définition des interfaces LAN/WAN et des ponts.
- `network_wireguard` : interfaces WireGuard à créer.
- `network_vlans` : configuration des VLANs (optionnel).

## Utilisation
```yaml
- hosts: routeurs
  roles:
    - role: network
      vars:
        network_wireguard:
          enabled: true
          interfaces:
            - name: wg0
              address: 10.0.0.1/24
```
