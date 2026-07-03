# Optional USB camera

Expose a UVC webcam plugged into the UNO Q to Home Assistant using
[go2rtc](https://github.com/AlexxIT/go2rtc).

## 1. Check the camera is detected

```bash
ls -l /dev/video*
v4l2-ctl --list-devices        # sudo apt-get install v4l-utils if missing
v4l2-ctl --list-formats-ext    # see supported resolutions/formats
```

Set `CAMERA_DEVICE` in `.env` if it isn't `/dev/video0`, and tweak
`input_format` / `video_size` in `go2rtc.yaml` to a mode your camera supports.

## 2. Start go2rtc

```bash
docker compose --profile camera up -d go2rtc
```

Check the stream at **http://<uno-q-ip>:1984** (go2rtc web UI).

## 3. Add it to Home Assistant

Settings → Devices & Services → **Add Integration** → **Generic Camera**:

- **Stream source URL:** `rtsp://127.0.0.1:8554/usb_camera`
- (still image URL can be left blank; the stream provides snapshots)

Motion detection, recording, etc. can then be layered on via HA automations or
add-ons as you like.
