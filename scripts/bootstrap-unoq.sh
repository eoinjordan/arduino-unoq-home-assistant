#!/usr/bin/env bash
# Bootstrap the Arduino UNO Q for the Home Assistant voice hub.
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"

echo "==> Checking Docker"
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Install it (the UNO Q usually ships with it via App Lab):"
  echo "  curl -fsSL https://get.docker.com | sh"
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is installed but not running. Starting it..."
  sudo systemctl start docker
fi
echo "    Docker: $(docker --version)"

echo "==> Ensuring your user can run docker without sudo"
if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"
  echo "    Added $USER to the docker group. Log out/in (or reboot) for it to take effect."
fi

echo "==> Preparing data directories"
mkdir -p data/whisper data/piper data/openwakeword homeassistant

echo "==> Preparing .env"
if [ ! -f .env ]; then
  cp .env.example .env
  echo "    Created .env from .env.example — edit it before starting."
fi

echo "==> Preparing Home Assistant secrets"
if [ ! -f homeassistant/secrets.yaml ]; then
  cp homeassistant/secrets.yaml.example homeassistant/secrets.yaml
  echo "    Created homeassistant/secrets.yaml — edit as needed."
fi

echo
echo "Next steps:"
echo "  1. nano .env                 # timezone, wake word, voice, audio devices"
echo "  2. ./scripts/setup-audio.sh  # find your mic/speaker device names"
echo "  3. docker compose up -d      # start Home Assistant + voice services"
echo "  4. Open http://<uno-q-ip>:8123 and finish onboarding"
echo "  5. ./wyoming-satellite/install.sh && ./wyoming-satellite/run.sh"
