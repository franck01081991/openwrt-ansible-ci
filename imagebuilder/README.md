# ImageBuilder

Utilitaires pour construire des images OpenWrt personnalisées contenant les paquets nécessaires à Ansible.

## Utilisation
```bash
cd imagebuilder
./build.sh \
  --release 24.10.0 \
  --target ramips \
  --subtarget mt7621 \
  --profile xiaomi_mi-router-4a-gigabit
# paquets ajoutés : python3 openssh-sftp-server ca-bundle ca-certificates
```
> Vérifier sur openwrt.org la combinaison `release/target/subtarget/profile` correspondant au matériel.

Personnalisation :
- **PACKAGES** : liste de paquets supplémentaires.
- **files/** : overlay (bannières, `uci-defaults`, clés SSH…).

Le script télécharge l’ImageBuilder, exécute la compilation puis supprime les fichiers temporaires. Les images générées sont stockées dans `imagebuilder/bin/targets/...`.
