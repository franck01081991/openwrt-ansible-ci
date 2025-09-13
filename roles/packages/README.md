# Rôle packages

## Objectif
Installe des paquets supplémentaires via `opkg`.

## Variables
- `packages_opkg_packages` (list) : paquets à installer

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: packages
      vars:
        packages_opkg_packages:
          - htop
          - tcpdump
```
