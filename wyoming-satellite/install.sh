#!/usr/bin/env bash
# Install the native Wyoming Satellite on the Arduino UNO Q.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing audio + build dependencies"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  git python3 python3-venv python3-pip \
  alsa-utils libopenblas0 \
  pulseaudio-utils

echo "==> Fetching wyoming-satellite"
cd "$HERE"
if [ ! -d wyoming-satellite ]; then
  git clone https://github.com/rhasspy/wyoming-satellite.git
fi

echo "==> Setting up the satellite virtualenv"
cd wyoming-satellite
script/setup

echo
echo "Done."
echo "  1. Edit ../.env (MIC_DEVICE, SND_COMMAND, WAKEWORD)"
echo "  2. Test:      $HERE/run.sh"
echo "  3. Autostart: see wyoming-satellite/README.md (systemd)"
