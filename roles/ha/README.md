# Rôle ha

Met en place la haute disponibilité avec `keepalived` et VRRP.

## Variables
- `ha_enabled` : active la fonctionnalité (défaut : `false`).
- `ha_vrrp_instances` : définition des instances VRRP.

## Utilisation
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
