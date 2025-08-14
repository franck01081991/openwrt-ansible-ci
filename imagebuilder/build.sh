#!/usr/bin/env bash
set -euo pipefail

RELEASE=""
TARGET=""
SUBTARGET=""
PROFILE=""
PACKAGES="python3-light openssh-sftp-server ca-bundle ca-certificates"
EXTRA_OPTS=""
WORKDIR="$(pwd)"

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

echo "[*] Téléchargement ImageBuilder: ${IB_URL}"
curl -fL -o "${TAR}" "${IB_URL}"
tar -xf "${TAR}"
cd "openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64"

mkdir -p "${WORKDIR}/files"
echo "[*] Build image profile=${PROFILE} packages='${PACKAGES}'"
make image PROFILE="${PROFILE}" PACKAGES="${PACKAGES}" FILES="${WORKDIR}/files" ${EXTRA_OPTS}

echo "[*] Images construites dans: $(pwd)/bin/targets/${TARGET}/${SUBTARGET}"
