# Exemples de configuration

Chaque bloc peut être placé dans `group_vars/openwrt.yml` ou dans un fichier de variables hôte.

## IDS (Suricata)
```yaml
ids_enabled: true
ids_interface: br-lan  # interface à surveiller
```
Le rôle installe `suricata`, déploie `/etc/suricata/suricata.yaml` et redémarre le service en cas de changement.

## Logging centralisé
```yaml
logging_enabled: true
logging_server: log.example.com
logging_facility: '*'
```

## Fail2ban
```yaml
fail2ban_enabled: true
fail2ban_jails:
  - name: ssh
    port: ssh
    logpath: /var/log/auth.log
  - name: luci
    port: http,https
    logpath: /var/log/uhttpd-access.log
```

## Monitoring collectd
```yaml
monitoring_enabled: true
monitoring_plugins:
  - cpu
  - interface
  - memory
```
Ajouter le plugin `network` pour exporter les métriques vers un collecteur distant.

## NTP
```yaml
ntp_enabled: true
ntp_servers:
  - 0.pool.ntp.org
  - 1.pool.ntp.org
```

## VLAN IoT isolé
```yaml
network_vlans: &iot_vlan
  enabled: true
  list:
    - id: 20
      name: "iot"
      device: "br-lan"
      ports: ["lan2:u*", "lan3:t", "lan4:t"]
      iface:
        name: "iot"
        address: "192.168.20.1"
        netmask: "255.255.255.0"
        dhcp: { start: 50, limit: 100, leasetime: "12h" }
      firewall:
        restrict_to_internet: true
dnsdhcp_vlans: *iot_vlan
firewall_vlans: *iot_vlan
```

## Bird2
```yaml
routing_enabled: true
routing_protocol: bird2
routing_config: |
  router id 192.0.2.1;

  protocol device {}
  protocol direct {
    interface "*";
  }
```
Interfaces supplémentaires :
```yaml
routing_interfaces:
  - name: wan2
    proto: dhcp
    device: eth1
```

## Haute disponibilité VRRP
```yaml
ha_enabled: true
ha_vrrp_instances:
  - name: VI_LAN
    state: MASTER
    interface: br-lan
    priority: 101
    virtual_ip: 192.168.10.254
```
Basculer manuellement :
```bash
ssh root@routeur1 /etc/init.d/keepalived stop
```

## ImageBuilder
```bash
cd imagebuilder
./build.sh --release 24.10.0 --target ramips --subtarget mt7621 --profile xiaomi_mi-router-4a-gigabit
```

## Restauration
```bash
scp backup.tgz root@routeur:/tmp/
ssh root@routeur "tar xzf /tmp/backup.tgz -C /"
```

## Notes
- *Ports DSA* : adapter `network_config.bridge_ports` et `network_config.wan.device` selon le matériel.
- *Wi-Fi* : le rôle `wireless` fournit un template désactivé par défaut (`wireless_config`).
- *WireGuard* : variables `network_wireguard`/`firewall_wireguard` prêtes à l’emploi.
