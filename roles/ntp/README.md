# Rôle ntp

## Objectif
Installe et configure le service NTP pour synchroniser l’horloge.

## Variables
- `ntp_enabled` (bool) : active le service (`true` par défaut)
- `ntp_servers` (list) : serveurs NTP à contacter

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: ntp
      vars:
        ntp_servers:
          - 0.pool.ntp.org
          - 1.pool.ntp.org
```
