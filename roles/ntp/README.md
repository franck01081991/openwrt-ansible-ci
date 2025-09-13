# Rôle ntp

Installe et configure le démon NTP pour la synchronisation horaire.

## Variables
- `ntp_enabled` : active le service (défaut : `true`).
- `ntp_servers` : liste des serveurs NTP à contacter.

## Utilisation
```yaml
- hosts: routeurs
  roles:
    - role: ntp
      vars:
        ntp_servers:
          - 0.pool.ntp.org
          - 1.pool.ntp.org
```
