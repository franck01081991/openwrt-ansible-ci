# Exemples de configuration

## IDS (Suricata)
Activer l'IDS et définir l'interface d'écoute :
```yaml
ids_enabled: true
ids_interface: br-lan  # ou wan, eth0, etc.
```
Le rôle installe le paquet `suricata`, déploie `/etc/suricata/suricata.yaml` et active le service. Toute modification du template redémarre automatiquement le service via le handler « Restart suricata ».

## Logging
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

## Monitoring
```yaml
monitoring_enabled: true
monitoring_plugins:
  - cpu
  - interface
  - memory
```
Ajoutez de nouveaux plugins en les listant dans `monitoring_plugins`. Pour envoyer les métriques vers un collecteur distant, incluez le plugin `network` et configurez la section `Server` du template `collectd.conf.j2`.

## NTP
```yaml
ntp_enabled: true
ntp_servers:
  - 0.pool.ntp.org
  - 1.pool.ntp.org
```
Le rôle installe le démon `ntpd` qui synchronise l'horloge du routeur auprès de ces sources et peut servir de référence pour les clients du réseau.

## VLAN / IoT
Activer un VLAN isolé pour les objets connectés :
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
Ce template :
- crée `bridge-vlan` et l'interface `br-lan.<vid>`
- ajoute un DHCP si `iface.dhcp` est défini
- crée une zone `iot` vers Internet uniquement si `restrict_to_internet: true`

## Bird2
Activer le routage dynamique avec Bird2 :
```yaml
routing_enabled: true
routing_protocol: bird2
routing_config: |
  router id 192.0.2.1;

  protocol device {}
  protocol direct {
    interface "*";
  }

# Déclarer des interfaces supplémentaires si besoin
routing_interfaces:
  - name: wan2
    proto: dhcp
    device: eth1
```

## Haute disponibilité
Activer une adresse virtuelle partagée entre deux routeurs :
```yaml
ha_enabled: true
ha_vrrp_instances:
  - name: VI_LAN
    state: MASTER
    interface: br-lan
    priority: 101
    virtual_ip: 192.168.10.254
```
Pour provoquer une bascule, arrêter le service sur le maître :
```bash
ssh root@routeur1 /etc/init.d/keepalived stop
```
Le routeur secondaire adopte l'adresse virtuelle. Relancer le service pour revenir à l'état initial :
```bash
ssh root@routeur1 /etc/init.d/keepalived start
```

## ImageBuilder
Générer une image OpenWrt contenant les paquets utiles à Ansible :
```bash
cd imagebuilder
./build.sh --release 24.10.0 --target ramips --subtarget mt7621 --profile xiaomi_mi-router-4a-gigabit
```

## Restauration depuis une archive
```bash
scp backup.tgz root@routeur:/tmp/
ssh root@routeur "tar xzf /tmp/backup.tgz -C /"
```

## Notes
- **Ports DSA** : ajustez `network_config.bridge_ports` et `network_config.wan.device` selon votre matériel (`lan1..lan4`, `wan`, etc.).
- **WiFi** : le rôle `wireless` propose un template minimaliste désactivé par défaut (`wireless_config`).
- **WireGuard** : variables `network_wireguard`/`firewall_wireguard` prévues mais désactivées ; renseignez vos clés et peers.
