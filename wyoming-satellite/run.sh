#!/usr/bin/env bash
# Run the Wyoming Satellite using settings from the repo .env file.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

# Load .env if present.
if [ -f "$ROOT/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$ROOT/.env"
  set +a
fi

MIC_DEVICE="${MIC_DEVICE:-plughw:CARD=Device,DEV=0}"
WAKEWORD="${WAKEWORD:-ok_nabu}"
OWW_URI="${OWW_URI:-tcp://127.0.0.1:10400}"
SND_COMMAND="${SND_COMMAND:-aplay -D plughw:CARD=Device,DEV=0 -r 22050 -c 1 -f S16_LE -t raw}"

RUN="$HERE/wyoming-satellite/script/run"
if [ ! -x "$RUN" ]; then
  echo "wyoming-satellite is not installed yet. Run: $HERE/install.sh" >&2
  exit 1
fi

ARGS=(
  --name "unoq-satellite"
  --uri "tcp://0.0.0.0:10700"
  --mic-command "arecord -D ${MIC_DEVICE} -r 16000 -c 1 -f S16_LE -t raw"
  --wake-uri "${OWW_URI}"
  --wake-word-name "${WAKEWORD}"
)

# Only configure a speaker if SND_COMMAND is non-empty (Wi-Fi speaker users leave it blank).
if [ -n "${SND_COMMAND}" ]; then
  ARGS+=(--snd-command "${SND_COMMAND}")
fi

echo "==> Starting wyoming-satellite (mic=${MIC_DEVICE}, wake=${WAKEWORD})"
exec "$RUN" "${ARGS[@]}"
