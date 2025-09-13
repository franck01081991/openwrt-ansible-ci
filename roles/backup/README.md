# Rôle backup

Automatise la sauvegarde de la configuration OpenWrt via un script cron.

## Variables
- `backup_enabled` (booléen) : active la sauvegarde. Valeur par défaut : `true`.
- `backup_destination` (chaîne) : destination `scp`/`rsync` des sauvegardes.
- `backup_schedule` (chaîne) : expression cron définissant la planification.

## Utilisation
```yaml
- hosts: routeurs
  roles:
    - role: backup
      vars:
        backup_destination: "user@backup-server:/backups"
```
