# Rôle dnsdhcp

## Objectif
Configure les services DNS et DHCP via `dnsmasq`.

## Variables
- `dnsdhcp_config` (dict) : paramètres DHCP
- `dnsdhcp_network` (dict) : interfaces LAN/WAN
- `dnsdhcp_vlans` (dict) : VLANs (optionnel)

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: dnsdhcp
      vars:
        dnsdhcp_config:
          lan_dhcp:
            start: 10
            limit: 50
            leasetime: "12h"
```
