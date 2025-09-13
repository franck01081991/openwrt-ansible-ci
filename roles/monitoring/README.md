# Rôle monitoring

## Objectif
Déploie `collectd` pour collecter des métriques système.

## Variables
- `monitoring_enabled` (bool) : active la collecte (`true` par défaut)
- `monitoring_plugins` (list) : plugins `collectd` à activer

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: monitoring
      vars:
        monitoring_plugins:
          - cpu
          - memory
```
