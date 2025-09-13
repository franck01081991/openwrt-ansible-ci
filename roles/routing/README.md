# Rôle routing

## Objectif
Active le routage dynamique avec `bird2`.

## Variables
- `routing_enabled` (bool) : active le rôle (`false` par défaut)
- `routing_protocol` (string) : protocole utilisé (`bird2` par défaut)
- `routing_config` (string) : configuration BIRD
- `routing_interfaces` (list) : interfaces additionnelles

## Exemple
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
