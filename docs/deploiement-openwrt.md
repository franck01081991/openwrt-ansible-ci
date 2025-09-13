# Guide de déploiement OpenWrt Ansible

## Objectif
Ce document explique pas à pas comment utiliser ce dépôt Ansible pour configurer des routeurs OpenWrt via un flux GitOps.

## 1. Architecture du dépôt
- `inventories/` : définitions des hôtes (`hosts.ini`) pour `lab`, `staging`, `production`.
- `group_vars/openwrt.yml` : variables communes (réseau, paquets, WireGuard, VLANs…).
- `playbooks/bootstrap.yml` : installe `python3-light` et `openssh-sftp-server` sur les routeurs.
- `playbooks/site.yml` : applique l’ensemble des rôles (`base`, `network`, `firewall`, etc.).
- `imagebuilder/` : génère des images OpenWrt personnalisées.

## 2. Prérequis
- Poste Linux ou macOS avec Git, Python ≥3.11 et Ansible ≥2.14.
- Accès SSH clé publique vers `root@routeur`.
- Connectivité IPv4/IPv6 vers les routeurs cibles.

## 3. Clonage et installation
```bash
git clone https://example.com/openwrt-ansible-ci.git
cd openwrt-ansible-ci
ansible-galaxy collection install -r requirements.yml
```

## 4. Gestion des secrets (SOPS/age)

1. Générer une clé age :

   ```bash
   age-keygen -o ~/.config/sops/age/keys.txt
   ```
2. Créer `.sops.yaml` :

   ```yaml
   keys:
     - age1example...
   creation_rules:
     - path_regex: inventories/.*/group_vars/.*secrets.yml$
       age: age1example...
   ```
3. Chiffrer un fichier de variables sensibles :

   ```bash
   sops inventories/production/group_vars/secrets.yml
   ```

## 5. Construction d’une image OpenWrt personnalisée

```bash
cd imagebuilder
./build.sh --release 24.10.0 --target ramips --subtarget mt7621 --profile xiaomi_mi-router-4a-gigabit
```

## 6. Inventaire et variables

```ini
# inventories/production/hosts.ini
[openwrt]
router1 ansible_host=192.168.1.1
```

## 7. Bootstrap initial

```bash
ansible-playbook -i inventories/production/hosts.ini playbooks/bootstrap.yml
```

## 8. Déploiement GitOps

```bash
git checkout -b feat/config-router1
git commit -am "feat: configure router1 vlan iot"
git push origin feat/config-router1
```

* CI: `yamllint .`, `ansible-lint -v`, `shellcheck imagebuilder/build.sh`, `ansible-playbook --syntax-check`.
* Post-merge: `ansible-playbook -i inventories/production/hosts.ini playbooks/site.yml` via workflow protégé.

## 9. Rollback

```bash
git revert <commit>
scp backup.tgz root@routeur:/tmp/
ssh root@routeur "tar xzf /tmp/backup.tgz -C /"
```

## 10. Commandes utiles

```bash
ansible-lint -v
yamllint .
shellcheck imagebuilder/build.sh
ansible-playbook -i inventories/production/hosts.ini --syntax-check playbooks/site.yml
ansible-playbook -i inventories/production/hosts.ini playbooks/site.yml
```

## 11. Ressources

* [OpenWrt](https://openwrt.org)
* [Ansible](https://docs.ansible.com)
* [SOPS](https://github.com/getsops/sops)
