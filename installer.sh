#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/alegarsan11/nftables-gui.git"
INSTALL_DIR="/opt/nftables-gui"

echo "==> Pulizia installazione precedente"
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo chown "$USER:$USER" "$INSTALL_DIR"

echo "==> Clonazione repository"
git clone "$REPO_URL" "$INSTALL_DIR"

echo "==> Installazione dipendenze di sistema"
sudo apt update
sudo apt install -y python3-nftables python3-venv python3-dev build-essential

echo "==> Creazione virtualenv (non root, con system-site-packages)"
python3 -m venv --system-site-packages "$INSTALL_DIR/venv"

echo "==> Attivazione virtualenv"
# shellcheck disable=SC1090
source "$INSTALL_DIR/venv/bin/activate"

echo "==> Aggiornamento pip"
pip install --upgrade pip

echo "==> Installazione dipendenze del progetto"
pip install -r "$INSTALL_DIR/requirements.txt"

echo "==> Installazione gunicorn + gevent"
pip install gunicorn gevent

echo "==> Fix compatibilità NumPy per hug"
pip install "numpy<2.0"

echo "==> Creazione directory log e run"
mkdir -p "$INSTALL_DIR/log" "$INSTALL_DIR/run"

echo "==> Verifica modulo nftables"
python3 - << 'EOF'
import nftables
print("OK: nftables importabile da:", nftables.__file__)
EOF

echo "==> Installazione completata con successo!"
echo "Puoi ora avviare la GUI con:"
echo "  sudo $INSTALL_DIR/start.sh start"
