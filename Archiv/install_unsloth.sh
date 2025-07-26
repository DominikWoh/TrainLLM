#!/usr/bin/env bash
# install_unsloth.sh  – Ubuntu 24.04 Server, RTX 2070 Super

set -e
LOG="$HOME/unsloth_install.log"

exec > >(tee -a "$LOG") 2>&1
echo "===== Unsloth One-Shot Installer ====="

# -------------------------------------------------
# Teil 0 – ggf. Root-Rechte holen
# -------------------------------------------------
if [[ $EUID -ne 0 && -z "$AFTER_REBOOT" ]]; then
    echo "Hole Root-Rechte für Treiber-Installation …"
    sudo "$0" "$@"
    exit $?
fi

# -------------------------------------------------
# Teil 1 – Treiber installieren (nur beim 1. Durchlauf)
# -------------------------------------------------
if [[ -z "$AFTER_REBOOT" ]]; then
    echo "[1] System aktualisieren und NVIDIA-Treiber installieren"
    apt update && apt dist-upgrade -y
    apt install -y linux-headers-$(uname -r) build-essential curl wget software-properties-common
    apt install -y nvidia-driver-550 nvidia-dkms-550

    # Kennzeichen setzen und Reboot auslösen
    echo "Reboot in 5 Sekunden…"
    sleep 5
    sudo reboot
    exit 0
fi

# -------------------------------------------------
# Teil 2 – nach dem Reboot
# -------------------------------------------------
echo "[2] Miniconda installieren (falls nötig)"
if [[ ! -d "$HOME/miniconda3" ]]; then
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p "$HOME/miniconda3"
    rm miniconda.sh
fi
source "$HOME/miniconda3/etc/profile.d/conda.sh"

echo "[3] Conda-Umgebung erstellen"
conda create -n unsloth python=3.11 -y
conda activate unsloth

echo "[4] PyTorch + CUDA 12.4"
conda install pytorch==2.5.1 torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y

echo "[5] Unsloth installieren"
pip install --upgrade pip
pip install "unsloth[cu124-torch250] @ git+https://github.com/unslothai/unsloth.git"

echo "[6] Kurzer Test"
python - <<'PY'
import torch, unsloth, os, sys
if not torch.cuda.is_available():
    print("❌ CUDA nicht verfügbar – Abbruch"); sys.exit(1)
print("✅ CUDA verfügbar:", torch.version.cuda)
print("✅ GPU:", torch.cuda.get_device_name(0))
PY

echo "===== Fertig! Umgebung aktivieren mit: conda activate unsloth ====="
