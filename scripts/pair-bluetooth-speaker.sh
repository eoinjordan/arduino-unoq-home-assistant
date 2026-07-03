#!/usr/bin/env bash
# Interactive helper to pair and trust a Bluetooth speaker on the UNO Q.
set -euo pipefail

echo "==> Ensuring Bluetooth packages are present"
if ! command -v bluetoothctl >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends bluez pulseaudio-module-bluetooth pulseaudio-utils
fi

echo "==> Making sure the Bluetooth service is running"
sudo systemctl enable --now bluetooth

cat <<'EOF'

Put your speaker into pairing mode, then run these inside bluetoothctl
(this script will drop you into it):

  power on
  agent on
  default-agent
  scan on
        # ... wait for your speaker's MAC address to appear ...
  scan off
  pair   <MAC>
  trust  <MAC>
  connect <MAC>
  quit

After connecting, verify it's the default audio sink:
  pactl list short sinks
  pactl set-default-sink <sink-name>

Then set SND_COMMAND in .env to the paplay form (see .env.example / docs/speakers.md).
EOF

echo
read -r -p "Press Enter to open bluetoothctl..."
bluetoothctl
