#!/bin/bash

mkdir -p /run/dbus
dbus-daemon --system --fork || true

su - adminotaur -c "vncserver -kill :1" >/dev/null 2>&1 || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

ADMIN_UID=$(id -u adminotaur)
RUNTIME_DIR="/tmp/runtime-${ADMIN_UID}"
install -d -o adminotaur -g adminotaur -m 700 "${RUNTIME_DIR}"

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

su - adminotaur -c "
  export XDG_RUNTIME_DIR='${RUNTIME_DIR}'
  export XDG_DATA_DIRS='/usr/local/share:/usr/share'
  vncserver :1 \
    -rfbport 5901 \
    -localhost no \
    -SecurityTypes None \
    --I-KNOW-THIS-IS-INSECURE
"

# Use a glob like the Debian baseline so the tail never 404s if
# TigerVNC names the log file differently (it includes the container
# hostname, which under rootless Podman is the container ID).
exec tail -F /home/adminotaur/.vnc/*:1.log
