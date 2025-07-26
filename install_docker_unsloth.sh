#!/usr/bin/env bash
# install_unsloth_docker.sh – Ubuntu 24.04 Server, RTX 2070 Super, RTX 30xx/40xx
# One-Shot: Treiber, Docker, NVIDIA-Toolkit, Conda-TOS, Unsloth & Jupyter
set -e

# Nur als root ausführen
[[ $EUID -ne 0 ]] && { echo "Run as root: sudo ./install_unsloth_docker.sh"; exit 1; }

# -------------------------------------------------
# 1) System aktualisieren & NVIDIA-Treiber installieren
# -------------------------------------------------
echo "[1] Updating system & installing NVIDIA driver 550"
apt update && apt dist-upgrade -y
apt install -y linux-headers-$(uname -r) build-essential curl wget git software-properties-common
apt install -y nvidia-driver-550 nvidia-dkms-550

# -------------------------------------------------
# 2) Docker + NVIDIA Container Toolkit
# -------------------------------------------------
echo "[2] Installing Docker & NVIDIA Container Toolkit"
curl -fsSL https://get.docker.com | bash
usermod -aG docker "$SUDO_USER"
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt update && apt install -y nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

# -------------------------------------------------
# 3) Projektordner + Dateien
# -------------------------------------------------
WORKDIR="/home/$SUDO_USER/unsloth-docker"
mkdir -p "$WORKDIR"
chown "$SUDO_USER:$SUDO_USER" "$WORKDIR"
cd "$WORKDIR"

# Dockerfile
cat > Dockerfile <<'EOF'
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential git curl wget vim && rm -rf /var/lib/apt/lists/*

# Miniconda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && rm miniconda.sh
ENV PATH="/opt/conda/bin:$PATH"

COPY unsloth_env.yml .
RUN conda config --set auto_activate_base false && \
    conda tos accept --override-channels --channel defaults && \
    conda env create -f unsloth_env.yml
SHELL ["conda", "run", "-n", "unsloth_env", "/bin/bash", "-c"]

RUN pip install --upgrade pip && \
    pip install "unsloth[cu124-torch250] @ git+https://github.com/unslothai/unsloth.git"

WORKDIR /workspace
CMD ["conda","run","--no-capture-output","-n","unsloth_env", \
     "jupyter","lab","--ip=0.0.0.0","--port=8888","--no-browser","--allow-root", \
     "--NotebookApp.token=12345678","--NotebookApp.password=''"]
EOF

# Conda-Umgebung
cat > unsloth_env.yml <<'EOF'
name: unsloth_env
channels:
  - pytorch
  - nvidia
  - conda-forge
dependencies:
  - python=3.11
  - pytorch==2.5.1
  - torchvision
  - torchaudio
  - pytorch-cuda=12.4
  - jupyterlab
  - ipykernel
  - pip
  - pip:
      - datasets
      - transformers
      - accelerate
      - hf_transfer
EOF

# Docker-Compose
cat > docker-compose.yml <<'EOF'
services:
  unsloth:
    build: .
    container_name: unsloth_jupyter
    restart: unless-stopped
    volumes:
      - ./workspace:/workspace
    ports:
      - "8888:8888"
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - JUPYTER_TOKEN=12345678
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
EOF

# -------------------------------------------------
# 4) Build & Start
# -------------------------------------------------
echo "[3] Building & starting container (~5-10 min) ..."
sudo -u "$SUDO_USER" docker compose up --build -d

# -------------------------------------------------
# 5) IP anzeigen
# -------------------------------------------------
IP=$(hostname -I | awk '{print $1}')
echo "✅ Ready!  http://$IP:8888  (token: 12345678)"
