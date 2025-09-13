# Rôle mptcp

## Objectif
Active le support Multipath TCP et démarre le service `mptcpd`.

## Variables
- `mptcp_config` (dict) : configuration du rôle, clé `enabled` pour activer le support.

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: mptcp
      vars:
        mptcp_config:
          enabled: true
```
