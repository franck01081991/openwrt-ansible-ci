# Rôle ids

## Objectif
Déploie le système de détection d’intrusion Suricata.

## Variables
- `ids_enabled` (bool) : active l'installation (`false` par défaut)
- `ids_interface` (string) : interface réseau surveillée (`br-lan` par défaut)

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: ids
      vars:
        ids_enabled: true
        ids_interface: br-wan
```
