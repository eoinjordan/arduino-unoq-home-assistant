#!/usr/bin/env bash
# Discover audio devices for the .env file (MIC_DEVICE / SND_COMMAND).
set -euo pipefail

echo "======================================================================"
echo " ALSA capture devices (microphones)  ->  MIC_DEVICE"
echo "======================================================================"
arecord -l 2>/dev/null || echo "  (arecord not found: sudo apt-get install alsa-utils)"
echo
echo "  Build MIC_DEVICE from the card name, e.g.:  plughw:CARD=Device,DEV=0"
echo "  List by name:"
arecord -L 2>/dev/null | grep -E '^plughw|^hw|^default' || true

echo
echo "======================================================================"
echo " ALSA playback devices (speakers)     ->  SND_COMMAND (aplay -D ...)"
echo "======================================================================"
aplay -l 2>/dev/null || true
echo
aplay -L 2>/dev/null | grep -E '^plughw|^hw|^default' || true

echo
echo "======================================================================"
echo " PulseAudio / PipeWire sinks          ->  Bluetooth / Wi-Fi speakers"
echo "======================================================================"
if command -v pactl >/dev/null 2>&1; then
  pactl list short sinks || true
  echo
  echo "  Default sink: $(pactl info 2>/dev/null | grep 'Default Sink' || echo 'n/a')"
else
  echo "  pactl not found (sudo apt-get install pulseaudio-utils) — only needed for Bluetooth."
fi

echo
echo "Put the chosen values in .env:  MIC_DEVICE=...  and  SND_COMMAND=..."
