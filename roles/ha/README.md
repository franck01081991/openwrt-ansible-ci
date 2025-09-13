# Rôle ha

## Objectif
Met en place la haute disponibilité avec `keepalived` et VRRP.

## Variables
- `ha_enabled` (bool) : active la fonctionnalité (`false` par défaut)
- `ha_vrrp_instances` (list) : instances VRRP à configurer

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: ha
      vars:
        ha_enabled: true
        ha_vrrp_instances:
          - name: LAN
            interface: br-lan
            virtual_ip: 192.168.1.254
```
