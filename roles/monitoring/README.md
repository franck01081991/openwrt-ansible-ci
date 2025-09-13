# Rôle monitoring

Installe `collectd` pour collecter des métriques système.

## Variables
- `monitoring_enabled` : active la collecte (défaut : `true`).
- `monitoring_plugins` : plugins collectd à activer.

## Utilisation
```yaml
- hosts: routeurs
  roles:
    - role: monitoring
      vars:
        monitoring_plugins:
          - cpu
          - memory
```
