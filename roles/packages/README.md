# Rôle packages

Installe des paquets supplémentaires via `opkg`.

## Variables
- `packages_opkg_packages` : liste des paquets à installer.

## Utilisation
```yaml
- hosts: routeurs
  roles:
    - role: packages
      vars:
        packages_opkg_packages:
          - htop
          - tcpdump
```
