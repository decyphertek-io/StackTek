#!/bin/bash

dbus-daemon --system --fork || true

# Clear any stale X11 lock / socket from a previous stop+start cycle.
su - adminotaur -c "vncserver -kill :1" >/dev/null 2>&1 || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# PipeWire/WirePlumber/pipewire-pulse all want XDG_RUNTIME_DIR. Containers
# don't ship one, so create it and reuse it for every su below.
ADMIN_UID=$(id -u adminotaur)
RUNTIME_DIR="/tmp/runtime-${ADMIN_UID}"
install -d -o adminotaur -g adminotaur -m 700 "${RUNTIME_DIR}"

# ── Audio stack (best-effort — VNC must start regardless of audio status) ──
# Start pipewire first; wait up to 5s for its socket; then wire up pulse.
su - adminotaur -c "
  export XDG_RUNTIME_DIR='${RUNTIME_DIR}'
  setsid pipewire </dev/null >/tmp/pipewire.log 2>&1 &
" || true

for _ in $(seq 1 50); do
  [ -S "${RUNTIME_DIR}/pipewire-0" ] && break
  sleep 0.1
done

su - adminotaur -c "
  export XDG_RUNTIME_DIR='${RUNTIME_DIR}'
  setsid wireplumber    </dev/null >/tmp/wireplumber.log 2>&1 &
  setsid pipewire-pulse </dev/null >/tmp/pw-pulse.log    2>&1 &
" || true

for _ in $(seq 1 50); do
  su - adminotaur -c "XDG_RUNTIME_DIR='${RUNTIME_DIR}' pactl info" >/dev/null 2>&1 && break
  sleep 0.1
done

su - adminotaur -c "
  export XDG_RUNTIME_DIR='${RUNTIME_DIR}'
  pactl load-module module-null-sink sink_name=stacktek_sink \
    sink_properties=device.description=stacktek-sink rate=48000 channels=2
  pactl load-module module-simple-protocol-tcp \
    source=stacktek_sink.monitor record=true \
    rate=48000 format=s16le channels=2 \
    listen=0.0.0.0 port=4713
  pactl set-default-sink stacktek_sink
" || echo "[stacktek] audio init failed — continuing without sound" >&2

# ── TigerVNC ──
# SecurityTypes None: auth is handled by the StackTek session cookie.
# XDG_DATA_DIRS is exported here so vncserver inherits it before xstartup
# runs, ensuring the desktop's GSettings schemas are found immediately.
su - adminotaur -c "
  export XDG_RUNTIME_DIR='${RUNTIME_DIR}'
  export XDG_DATA_DIRS='/usr/local/share:/usr/share'
  vncserver :1 \
    -rfbport 5901 \
    -localhost no \
    -SecurityTypes None \
    --I-KNOW-THIS-IS-INSECURE
"

# Hold the container open and surface desktop/TigerVNC errors via `podman logs`.
exec tail -F /home/adminotaur/.vnc/*:1.log
