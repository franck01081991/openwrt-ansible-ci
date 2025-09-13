# Rôle logging

## Objectif
Redirige les journaux système vers un serveur `rsyslog` centralisé.

## Variables
- `logging_enabled` (bool) : active la redirection (`false` par défaut)
- `logging_server` (string) : adresse du serveur
- `logging_facility` (string) : facilités à transférer

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: logging
      vars:
        logging_enabled: true
        logging_server: log.example.com
        logging_facility: '*'
```
