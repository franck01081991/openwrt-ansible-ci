# Rôle base

Configure les paramètres système de base : nom d'hôte, fuseau horaire et clés SSH.

## Variables
- `base_system.hostname` : nom d'hôte (défaut : `openwrt`).
- `base_system.timezone` : fuseau horaire (défaut : `UTC`).
- `base_system.zonename` : zone OpenWrt (défaut : `UTC`).
- `base_system.ntp_servers` : liste des serveurs NTP.
- `base_system.authorized_keys` : clés publiques autorisées pour SSH.

## Utilisation
```yaml
- hosts: routeurs
  roles:
    - role: base
      vars:
        base_system:
          hostname: routeur01
          authorized_keys:
            - "ssh-rsa AAAA... utilisateur@example"
```
