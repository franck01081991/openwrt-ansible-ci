# Rôle wireless

## Objectif
Configure les interfaces Wi-Fi (SSID, clé, pays).

## Variables
- `wireless_config.enabled` (bool) : active le Wi-Fi (`false` par défaut)
- `wireless_config.country` (string) : code pays
- `wireless_config.ssid` (string) : nom du réseau
- `wireless_config.encryption` (string) : méthode de chiffrement
- `wireless_config.key` (string) : clé pré-partagée

## Exemple
```yaml
- hosts: routeurs
  roles:
    - role: wireless
      vars:
        wireless_config:
          enabled: true
          ssid: MonWifi
          key: secret1234
```
