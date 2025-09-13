# Rôle dnsdhcp

Gère les services DNS et DHCP via `dnsmasq` et la configuration réseau de base.

## Variables
- `dnsdhcp_config` : paramètres DHCP (plage, domaine…).
- `dnsdhcp_network` : interfaces LAN/WAN et ponts.
- `dnsdhcp_vlans` : définition des VLANs (optionnel).

## Utilisation
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
