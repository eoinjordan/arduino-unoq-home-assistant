# Arduino UNO Q — Home Assistant Voice Hub

A clean, **generic** Home Assistant voice-assistant setup that runs entirely on an
**Arduino UNO Q** (Qualcomm Dragonwing, Debian aarch64). No cloud, no vendor lock‑in.

- 🧠 **Home Assistant** in Docker on the UNO Q.
- 🎙️ **Voice input** from a mic connected to the UNO Q (the built‑in analog mic *or* a USB mic).
- 🗣️ **Local speech** — Whisper (STT), Piper (TTS) and openWakeWord (wake word) via the
  [Wyoming protocol](https://github.com/rhasspy/wyoming).
- 🔊 **Audio output** to a **Bluetooth** *or* **Wi‑Fi** speaker.
- 📷 **Optional USB camera** exposed to Home Assistant via go2rtc.

Everything here is generic — bring your own wake word, your own speaker, your own camera.

---

## Hardware

| Part | Notes |
| --- | --- |
| Arduino UNO Q | 2 GB or 4 GB. 4 GB is more comfortable for the voice stack. |
| Mic | Built‑in analog mic, **or** any USB microphone (recommended, easiest). |
| Speaker | Any **Bluetooth** speaker, **or** a **Wi‑Fi** speaker (Sonos / Chromecast / DLNA / AirPlay). |
| USB camera *(optional)* | Any UVC webcam (`/dev/video0`). |

---

## Architecture

```
 ┌──────────────────────── Arduino UNO Q (Debian aarch64) ────────────────────────┐
 │                                                                                 │
 │   USB / analog mic ──► wyoming-satellite ──► openWakeWord ─┐                     │
 │                              │                             │                     │
 │                              ▼                             ▼                     │
 │        Bluetooth /  ◄──── (TTS audio)             Home Assistant  ◄─► Whisper    │
 │        speaker out                                (Docker :8123)  ◄─► Piper      │
 │                                                        ▲                         │
 │   USB camera ──► go2rtc (optional) ────────────────────┘                         │
 └─────────────────────────────────────────────────────────────────────────────────┘
```

- **Docker** runs Home Assistant + the Wyoming services (Whisper, Piper, openWakeWord)
  and, optionally, go2rtc for the USB camera.
- **wyoming-satellite** runs **natively** on the UNO Q because it needs direct access to
  the audio hardware (mic + Bluetooth/USB speaker).

---

## Quick start

### 1. Clone on the UNO Q

```bash
cd ~
git clone https://github.com/eoinjordan/arduino-unoq-home-assistant.git
cd arduino-unoq-home-assistant
```

### 2. Bootstrap

```bash
./scripts/bootstrap-unoq.sh      # checks Docker, prepares config dirs, copies .env
```

### 3. Configure

```bash
cp .env.example .env
nano .env                        # set TZ, wake word, voice, and audio devices
```

Find your audio devices with:

```bash
./scripts/setup-audio.sh         # lists ALSA capture/playback + PulseAudio sinks
```

### 4. Start the core stack (Home Assistant + voice services)

```bash
docker compose up -d
docker compose logs -f homeassistant     # Ctrl+C to stop watching
```

Open **http://<uno-q-ip>:8123** and complete onboarding.

### 5. Add the Wyoming services in Home Assistant

Settings → Devices & Services → **Add Integration** → **Wyoming Protocol**, and add each of:

| Service | Host | Port |
| --- | --- | --- |
| Whisper (STT)      | `127.0.0.1` | `10300` |
| Piper (TTS)        | `127.0.0.1` | `10200` |
| openWakeWord       | `127.0.0.1` | `10400` |

Then Settings → **Voice assistants** → create/adjust a pipeline that uses Whisper + Piper.

### 6. Start the voice satellite (mic + speaker)

The satellite runs natively — see [`wyoming-satellite/README.md`](wyoming-satellite/README.md):

```bash
./wyoming-satellite/install.sh   # one‑time
./wyoming-satellite/run.sh       # foreground test
# or install the systemd service for auto‑start (see that README)
```

Say your wake word (default **"ok nabu"**) and talk to Home Assistant.

---

## Speaker output

You have two independent options — pick whichever suits your speaker.

### Bluetooth speaker (played by the satellite)

Pair it once, then point the satellite's playback command at the Bluetooth sink:

```bash
./scripts/pair-bluetooth-speaker.sh      # interactive bluetoothctl helper
```

Set `SND_COMMAND` in `.env` to use the Bluetooth sink (see `.env.example`).

### Wi‑Fi speaker (played by Home Assistant)

Add your speaker to Home Assistant as a media player (Sonos, Google Cast, DLNA, AirPlay/HomePod
via HomeKit, Snapcast, …). Then either:

- set that media player as the **output** of your Assist pipeline, or
- disable the satellite's local audio out (`SND_COMMAND=`) and let HA speak to the Wi‑Fi
  speaker via `tts.speak`.

See [`docs/speakers.md`](docs/speakers.md).

---

## Optional USB camera

Enable the `camera` Docker profile to run go2rtc, which turns `/dev/video0` into an
RTSP/WebRTC stream Home Assistant can consume:

```bash
docker compose --profile camera up -d
```

Then add a **Generic Camera** integration in HA with
`rtsp://127.0.0.1:8554/usb_camera`. See [`camera/README.md`](camera/README.md).

---

## Layout

```
docker-compose.yml        Home Assistant + Whisper + Piper + openWakeWord (+ go2rtc profile)
.env.example              All tunables (timezone, wake word, voice, audio devices)
Makefile                  Convenience targets (up/down/logs/…)
homeassistant/            HA configuration (generic, default_config based)
wyoming-satellite/        Native satellite (mic + speaker) install + run + systemd unit
camera/                   go2rtc config for an optional USB camera
scripts/                  bootstrap, audio discovery, Bluetooth pairing helpers
docs/                     Extra notes (speaker output options)
```

## License

MIT
