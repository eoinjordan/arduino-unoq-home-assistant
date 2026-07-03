# Wyoming Satellite (native on the UNO Q)

The satellite captures the microphone, runs the wake word (via the openWakeWord
Docker service), streams speech to Home Assistant, and plays TTS back to your
speaker. It runs **natively** on the UNO Q — not in Docker — so it has direct
access to the audio hardware (USB/analog mic and Bluetooth/USB speaker).

## Install (one-time)

```bash
./wyoming-satellite/install.sh
```

This installs system audio packages and sets up the upstream
[`wyoming-satellite`](https://github.com/rhasspy/wyoming-satellite) in its own venv.

## Configure

All settings come from the repo's `.env` file (`MIC_DEVICE`, `SND_COMMAND`,
`WAKEWORD`). Discover your audio device names first:

```bash
../scripts/setup-audio.sh
```

## Run (foreground test)

```bash
./wyoming-satellite/run.sh
```

Say the wake word (default **"ok nabu"**) and speak. Watch the Home Assistant logs
to confirm the pipeline runs.

## Auto-start with systemd

Edit `wyoming-satellite.service` so `WorkingDirectory`, `ExecStart` and `User`
match where you cloned the repo (default assumes `/home/arduino/arduino-unoq-home-assistant`),
then:

```bash
sudo cp wyoming-satellite/wyoming-satellite.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now wyoming-satellite
journalctl -u wyoming-satellite -f
```

## How it connects

- The satellite listens on `tcp://0.0.0.0:10700` and is **auto-discovered** by the
  Home Assistant Wyoming integration (you'll get a "Discovered" satellite to add).
- Wake word runs against the openWakeWord service at `tcp://127.0.0.1:10400`
  (the `openwakeword` Docker container).

## Speaker notes

- **USB / analog speaker** — default `SND_COMMAND` uses `aplay`.
- **Bluetooth speaker** — pair with `../scripts/pair-bluetooth-speaker.sh`, then set
  `SND_COMMAND` to the `paplay` form in `.env.example`.
- **Wi-Fi speaker** — set `SND_COMMAND=` (empty) and let Home Assistant speak to the
  speaker's media player instead. See `../docs/speakers.md`.
