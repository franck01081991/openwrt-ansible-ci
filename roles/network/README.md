# Rôle network

## Objectif
Gère les interfaces réseau, VLANs et tunnels WireGuard/VxLAN.

## Variables
- `network_config` (dict) : interfaces LAN/WAN et ponts
- `network_wireguard` (dict) : interfaces WireGuard
- `network_vlans` (dict) : définition des VLANs
- `network_vxlan` (dict) : tunnels VxLAN

## Exemple
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
