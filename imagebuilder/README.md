# ImageBuilder helper

Ce dossier facilite la création d'images OpenWrt custom incluant les paquets utiles à Ansible (ex: `python3-light`, `openssh-sftp-server`).

## Utilisation

```bash
cd imagebuilder
./build.sh \
  --release 24.10.0 \
  --target ramips \
  --subtarget mt7621 \
  --profile xiaomi_mi-router-4a-gigabit

# Exemple de paquets ajoutés :
# python3-light openssh-sftp-server ca-bundle ca-certificates
```

> ⚠️ Vérifie sur openwrt.org la combinaison `release/target/subtarget/profile` propre à ton matériel.

Tu peux personnaliser :
- `PACKAGES` : liste d'addons.
- `files/` : overlay (bannières, uci-defaults, clés SSH…).

Le script télécharge et extrait temporairement l'ImageBuilder puis supprime automatiquement l'archive et le dossier à la fin de l'exécution (ou en cas d'erreur). Les images générées sont conservées dans `imagebuilder/bin/targets/...`.
