# Rôle backup

## Objectif
Automatise la sauvegarde de la configuration OpenWrt via cron.

## Variables
- `backup_enabled` (bool) : active la sauvegarde (`true` par défaut)
- `backup_destination` (string) : destination `scp` ou `rsync`
- `backup_schedule` (string) : expression cron de planification

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: backup
      vars:
        backup_destination: "user@backup-server:/backups"
```
