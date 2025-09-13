# Rôle ids

Déploie le système de détection d'intrusion Suricata.

## Variables
- `ids_enabled` : active l'installation (défaut : `false`).
- `ids_interface` : interface réseau à surveiller (défaut : `br-lan`).

## Utilisation
```yaml
- hosts: routeurs
  roles:
    - role: ids
      vars:
        ids_enabled: true
        ids_interface: br-wan
```
