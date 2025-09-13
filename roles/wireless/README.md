# Rôle wireless

Configure le Wi-Fi (SSID, clé, pays) sur les interfaces radio.

## Variables
- `wireless_config.enabled` : active le Wi-Fi (défaut : `false`).
- `wireless_config.country` : code pays.
- `wireless_config.ssid` : nom du réseau.
- `wireless_config.encryption` : type de chiffrement.
- `wireless_config.key` : clé pré-partagée.

## Utilisation
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
