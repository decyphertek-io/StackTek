#!/bin/bash
set -e

export DOCKER_HOST="unix:///run/podman.sock"

if [ -n "$VULHUB_CVE" ]; then
  CVE_DIR="/vulhub/${VULHUB_CVE}"
  if [ ! -d "$CVE_DIR" ]; then
    echo "ERROR: CVE path not found: ${VULHUB_CVE}"
    echo "Available vendors:"
    ls /vulhub/ | head -30
    exec ttyd -p 7681 -c "admin:${TTYD_PASSWORD:-vulhub}" -W /bin/bash
  fi
  cd "$CVE_DIR"
  echo "Launching ${VULHUB_CVE}..."
  podman-compose up -d
  echo "Environment running. Use 'podman-compose logs' to view output."
fi

exec ttyd -p 7681 -c "admin:${TTYD_PASSWORD:-vulhub}" -W /bin/bash --rcfile <(cat <<'BASHRC'
export TERM=xterm-256color
export DOCKER_HOST="unix:///run/podman.sock"
cd /vulhub
echo ""
echo "Vulhub CVE Lab"
echo "  VULHUB_CVE=${VULHUB_CVE:-not set}"
echo "  Browse: cd /vulhub && ls"
echo "  Launch: cd <vendor>/<cve> && podman-compose up -d"
echo "  Stop:   cd <vendor>/<cve> && podman-compose down -v"
echo ""
BASHRC
)
