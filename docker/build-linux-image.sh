#!/bin/bash
# Baut das Docker-Image meine_nas_app:latest auf einer Linux-VM (oder Linux-PC)
# und exportiert es nach dist/meine_nas_app-image.tar fuer das Synology-NAS.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"
mkdir -p "$ROOT_DIR/dist"

echo "🔨 Baue Docker-Image meine_nas_app:latest (linux/amd64)..."
docker build --platform linux/amd64 -t "meine_nas_app:latest" .

TAR_FILE="$ROOT_DIR/dist/meine_nas_app-image.tar"
rm -f "$TAR_FILE"
echo "📦 Exportiere Image nach $TAR_FILE ..."
docker save -o "$TAR_FILE" "meine_nas_app:latest"

echo "✅ Fertig! Kopiere $TAR_FILE auf das NAS und starte dort:"
echo "   ./docker/load-nas-image.sh"
