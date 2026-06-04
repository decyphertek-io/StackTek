#!/bin/bash

dbus-daemon --system --fork || true

su - adminotaur -c "vncserver -kill :1" >/dev/null 2>&1 || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

ADMIN_UID=$(id -u adminotaur)
RUNTIME_DIR="/tmp/runtime-${ADMIN_UID}"
install -d -o adminotaur -g adminotaur -m 700 "${RUNTIME_DIR}"

su - adminotaur -c "
  export XDG_RUNTIME_DIR='${RUNTIME_DIR}'
  vncserver :1 \
    -rfbport 5901 \
    -localhost no \
    -SecurityTypes None \
    --I-KNOW-THIS-IS-INSECURE
"

exec tail -F /home/adminotaur/.vnc/*:1.log
