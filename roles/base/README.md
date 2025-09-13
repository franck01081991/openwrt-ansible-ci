# Rôle base

## Objectif
Configure les paramètres système essentiels : nom d’hôte, fuseau horaire et clés SSH.

## Variables
- `base_system.hostname` (string) : nom d’hôte (`openwrt` par défaut)
- `base_system.timezone` (string) : fuseau horaire (`UTC` par défaut)
- `base_system.zonename` (string) : zone OpenWrt (`UTC` par défaut)
- `base_system.ntp_servers` (list) : serveurs NTP
- `base_system.authorized_keys` (list) : clés publiques autorisées

## Exemple
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
