# Rôle fail2ban

## Objectif
Installe et configure `fail2ban` pour protéger les services exposés.

## Variables
- `fail2ban_enabled` (bool) : active le service (`true` par défaut)
- `fail2ban_jails` (list) : jails à appliquer

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: fail2ban
      vars:
        fail2ban_jails:
          - name: ssh
            enabled: true
            maxretry: 5
```
