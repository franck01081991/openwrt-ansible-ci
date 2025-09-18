# Guide de déploiement OpenWrt Ansible

Ce guide décrit la mise en œuvre de ce dépôt pour configurer des routeurs OpenWrt dans une démarche GitOps.

## 1. Architecture du dépôt
- `inventories/production/hosts.yml` : inventaire de référence
- `group_vars/openwrt.yml` : variables communes
- `playbooks/bootstrap.yml` : installe `python3` et `openssh-sftp-server`
- `playbooks/site.yml` : applique l’ensemble des rôles
- `imagebuilder/` : script pour créer des images OpenWrt personnalisées

## 2. Prérequis
- Poste Linux ou macOS avec Git, Python ≥ 3.11 et Ansible ≥ 2.14
- Accès SSH par clé publique vers `root@routeur`
- Connectivité réseau vers les équipements

## 3. Installation
```bash
git clone https://example.com/openwrt-ansible-ci.git
cd openwrt-ansible-ci
ansible-galaxy collection install -r requirements.yml
```

## 4. Gestion des secrets avec SOPS/age
1. Générer une clé :
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
3. Chiffrer un fichier :
   ```bash
   sops inventories/production/group_vars/secrets.yml
   ```

## 5. Construction d’une image OpenWrt
```bash
cd imagebuilder
./build.sh --release 24.10.0 --target ramips --subtarget mt7621 --profile xiaomi_mi-router-4a-gigabit
```

## 6. Inventaire et variables
```ini
# inventories/production/hosts.yml
[openwrt]
router1 ansible_host=192.168.1.1
```

## 7. Bootstrap initial
```bash
ansible-playbook -i inventories/production/hosts.yml playbooks/bootstrap.yml
# ou
make bootstrap INVENTORY=inventories/production/hosts.yml
```

## 8. Déploiement GitOps
```bash
git checkout -b feat/config-router1
git commit -am "feat: configure router1 vlan iot"
git push origin feat/config-router1
```
*CI :* `yamllint .`, `ansible-lint -v`, `shellcheck imagebuilder/build.sh`, `ansible-playbook --syntax-check`.

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
ansible-playbook -i inventories/production/hosts.yml --syntax-check playbooks/site.yml
ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml
# ou
make site INVENTORY=inventories/production/hosts.yml
```

## 11. Ressources
- [OpenWrt](https://openwrt.org)
- [Ansible](https://docs.ansible.com)
- [SOPS](https://github.com/getsops/sops)
