# Rôle network

## Objectif
Gère les interfaces réseau, VLANs et tunnels WireGuard/VxLAN.

## Variables
- `network_config` (dict) : interfaces LAN/WAN et ponts
- `network_wireguard` (dict) : interfaces WireGuard
- `network_vlans` (dict) : définition des VLANs
- `network_vxlan` (dict) : tunnels VxLAN (`enabled`, `tunnels[]` avec `name`, `id`, `local`, `remote`, `port`, `device`, `ipaddr`)

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
        network_vxlan:
          enabled: true
          tunnels:
            - name: vxlan10
              id: 10
              local: 192.0.2.1
              remote: 192.0.2.2
              port: 4789
              ipaddr: 10.10.10.1/24  # optionnel
```
