# Rôle logging

Configure l'envoi des logs système vers un serveur `rsyslog` centralisé.

## Variables
- `logging_enabled` : active la redirection (défaut : `false`).
- `logging_server` : adresse du serveur de logs.
- `logging_facility` : facilités à transférer.

## Utilisation
```yaml
- hosts: routeurs
  roles:
    - role: logging
      vars:
        logging_enabled: true
        logging_server: log.example.com
```
