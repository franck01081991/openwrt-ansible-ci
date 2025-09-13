# Rôle network

## Objectif
Gère les interfaces réseau, VLANs et tunnels WireGuard/VXLAN.

## Variables
- `network_config` (dict) : interfaces LAN/WAN et ponts
- `network_wireguard` (dict) : interfaces WireGuard
- `network_vlans` (dict) : définition des VLANs
- `network_vxlan` (dict) : tunnels VXLAN (`enabled`, `tunnels[]` avec `name`, `id`, `local`, `remote`, `port`, `device`, `ipaddr`)

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: network
      vars:
        network_vxlan:
          enabled: true
          tunnels:
            - name: vxlan10
              id: 10
              local: 192.0.2.1
              remote: 192.0.2.2
              port: 4789
              device: eth0            # optionnel
              ipaddr: 10.10.10.1/24  # optionnel
```
