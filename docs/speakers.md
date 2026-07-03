# Speaker output options

The satellite can play Text-to-Speech itself, or you can let Home Assistant speak
to a networked speaker. Pick whichever matches your hardware.

## Bluetooth speaker (played locally by the satellite)

1. Pair the speaker once:
   ```bash
   ./scripts/pair-bluetooth-speaker.sh
   ```
2. Confirm it's the default PulseAudio/PipeWire sink:
   ```bash
   pactl list short sinks
   pactl info | grep 'Default Sink'
   ```
3. In `.env`, set `SND_COMMAND` to the PulseAudio form:
   ```
   SND_COMMAND=paplay --raw --rate=22050 --channels=1 --format=s16le --device=@DEFAULT_SINK@
   ```
4. Restart the satellite.

> Bluetooth audio needs a running user audio server. If the satellite runs as a
> systemd **system** service, either run PulseAudio in system mode or run the
> satellite as a user service so it shares your session's audio.

## USB / analog speaker (played locally by the satellite)

Use the default ALSA form in `.env`:
```
SND_COMMAND=aplay -D plughw:CARD=Device,DEV=0 -r 22050 -c 1 -f S16_LE -t raw
```
Find the card name with `./scripts/setup-audio.sh`.

## Wi-Fi speaker (played by Home Assistant)

For Sonos, Google Cast/Nest, DLNA, AirPlay (HomePod via HomeKit), Snapcast, etc.:

1. Add the speaker to Home Assistant as a **media player** integration.
2. Disable the satellite's local audio out — set `SND_COMMAND=` (empty) in `.env`.
3. Speak responses from HA, e.g. in an automation/script:
   ```yaml
   - service: tts.speak
     target:
       entity_id: tts.piper
     data:
       media_player_entity_id: media_player.living_room_speaker
       message: "{{ message }}"
   ```
   Or set the media player as the output device of your Assist pipeline
   (Settings → Voice assistants → your pipeline).
