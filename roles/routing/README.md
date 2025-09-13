# Rôle routing

Active le routage dynamique avec `bird2`.

## Variables
- `routing_enabled` : active le rôle (défaut : `false`).
- `routing_protocol` : protocole utilisé (défaut : `bird2`).
- `routing_config` : configuration BIRD à appliquer.

## Utilisation
```yaml
- hosts: routeurs
  roles:
    - role: routing
      vars:
        routing_enabled: true
        routing_config: |
          router id 1.1.1.1;
          protocol kernel { export all; }
```
