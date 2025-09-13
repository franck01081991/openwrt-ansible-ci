# Rôle fail2ban

Installe et configure `fail2ban` pour protéger les services exposés.

## Variables
- `fail2ban_enabled` : active le service (défaut : `true`).
- `fail2ban_jails` : liste des *jails* à appliquer.

## Utilisation
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
