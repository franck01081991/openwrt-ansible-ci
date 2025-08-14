#!/usr/bin/env bash
set -euo pipefail

RELEASE=""
TARGET=""
SUBTARGET=""
PROFILE=""
PACKAGES="python3-light openssh-sftp-server ca-bundle ca-certificates"
EXTRA_OPTS=""
WORKDIR="$(pwd)"

# Ensure required tools are available
for cmd in curl tar sha256sum; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required tool '$cmd' not found." >&2
    exit 1
  fi
done

usage() {
  cat <<EOF
Usage: $0 --release <X.Y.Z> --target <target> --subtarget <sub> --profile <profile> [--packages "pkg1 pkg2"] [--extra 'KEY=VALUE']
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release) RELEASE="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --subtarget) SUBTARGET="$2"; shift 2;;
    --profile) PROFILE="$2"; shift 2;;
    --packages) PACKAGES="$2"; shift 2;;
    --extra) EXTRA_OPTS="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

[[ -z "$RELEASE" || -z "$TARGET" || -z "$SUBTARGET" || -z "$PROFILE" ]] && { usage; exit 1; }

IB_URL="https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${SUBTARGET}/openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"
TAR="openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"
SHA256_URL="${IB_URL}.sha256"
SHA256_FILE="${TAR}.sha256"

echo "[*] Téléchargement ImageBuilder: ${IB_URL}"
curl -fL -o "${TAR}" "${IB_URL}"
echo "[*] Téléchargement fichier SHA256: ${SHA256_URL}"
curl -fL -o "${SHA256_FILE}" "${SHA256_URL}"
echo "[*] Vérification de l'archive"
sha256sum -c "${SHA256_FILE}"
tar -xf "${TAR}"
cd "openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64"

mkdir -p "${WORKDIR}/files"
echo "[*] Build image profile=${PROFILE} packages='${PACKAGES}'"
make image PROFILE="${PROFILE}" PACKAGES="${PACKAGES}" FILES="${WORKDIR}/files" ${EXTRA_OPTS}

echo "[*] Images construites dans: $(pwd)/bin/targets/${TARGET}/${SUBTARGET}"
