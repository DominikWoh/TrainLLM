# 🦥 Unsloth One-Shot Installer (Ubuntu 24.04 + Docker + RTX 2070 Super)

Dieses Repository enthält ein **vollautomatisches Bash-Skript**, das Unsloth samt CUDA 12.4, NVIDIA-Treiber, Docker, Conda, PyTorch 2.5.1 und Jupyter Lab in einem **One-Shot-Vorgang** installiert.

✅ Kein manuelles Setup  
✅ Kein CUDA-Raten  
✅ Kein LLM-Frickeln  
✅ Alles GPU-beschleunigt, sofort nutzbar

---

## 🔧 Voraussetzungen

- Ubuntu **24.04 Server**
- **NVIDIA GPU** (z. B. RTX 2070 Super oder kompatibel mit CUDA 12.4)
- Internetverbindung
- Root-Zugriff (für `sudo`)

---

## 🚀 Schnellstart

```bash
git clone https://github.com/dominikwoh/TrainLLM.git
cd unsloth-oneshot
chmod +x install_unsloth_docker.sh
sudo ./install_unsloth_docker.sh
```

📦 Das Skript installiert automatisch:

- NVIDIA-Treiber **550**
- Docker & NVIDIA Container Toolkit
- `unsloth_env` Conda-Umgebung
- Jupyter Lab mit Token-Login
- Quant-ready Setup für GGUF-Export

---

## 🌍 Zugriff auf Jupyter Lab

Öffne deinen Browser und rufe auf:

```
http://<DEINE_SERVER_IP>:8888
```

🔐 Login-Token: `12345678`

📁 Alle Notebooks liegen im Ordner `workspace/` (automatisch gemountet).

---

## 📄 Export als GGUF

Nach dem Training kannst du dein Modell direkt in GGUF exportieren:

```python
from unsloth import save_to_gguf

# LoRA + Base zusammenführen
model.save_pretrained_merged("merged", tokenizer, save_method="merged_16bit")

# Exportieren
save_to_gguf("merged", quantization_method="q4_k_m")
```

Ergebnis: `merged-q4_k_m.gguf` → kompatibel mit llama.cpp, ollama, koboldcpp, etc.

---

## 🔁 Container neu starten

```bash
cd ~/unsloth-docker
docker compose up -d
```

---

## 🛯️ Container stoppen / entfernen

```bash
docker compose down
docker image rm unsloth-docker-unsloth
```

---

## 📝 Lizenz

MIT – feel free to fork & improve!


1. Server neustarten
Führe einen sauberen Neustart durch, damit der neue Kernel und der NVIDIA-Treiber geladen werden:
Generated bash
sudo reboot
Use code with caution.
Bash
2. Nach dem Neustart: Treiber überprüfen
Logge dich wieder ein und überprüfe, ob der NVIDIA-Treiber jetzt korrekt läuft. Gib diesen Befehl ein:
Generated bash
nvidia-smi
Use code with caution.
Bash
Wenn alles geklappt hat, solltest du eine Tabelle sehen, die deine RTX 2070 Super auflistet, zusammen mit der Treiberversion (sollte 550 sein) und dem CUDA-Level.
3. Container neu starten
Da der Treiber nun läuft, können wir den Container, dessen Image bereits fertig gebaut wurde, einfach starten.
Generated bash
# Wechsle wieder in den Projektordner
cd /home/user/unsloth-docker/

# Starte den Container (diesmal wird es sehr schnell gehen)
docker compose up -d
Use code with caution.
Bash
Der Befehl docker compose up -d startet die in docker-compose.yml definierten Dienste im Hintergrund (-d für "detached").
Du kannst mit docker ps überprüfen, ob der Container unsloth_jupyter jetzt läuft.



## Im Jupyter Notebook Terminal:


```
# Installiert alle benötigten System-Tools (cmake, libcurl)
!apt-get update && apt-get install -y cmake libcurl4-openssl-dev

# Klont llama.cpp (falls noch nicht vorhanden) und kompiliert es mit der neuen CMake-Methode
!git clone https://github.com/ggerganov/llama.cpp.git
!cd llama.cpp && rm -rf build && mkdir build && cd build && cmake .. && cmake --build .

print("\n✅ Vorbereitung abgeschlossen. Llama.cpp ist jetzt kompiliert.")
```


