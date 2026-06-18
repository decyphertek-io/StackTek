#!/bin/bash
# Hermes Agent bootstrap. Generates a fresh API_SERVER_KEY and writes the
# .env the compose file reads via env_file.
#
# IMPORTANT — do NOT edit the API key values below by pasting into `vi`:
# terminals emit bracketed-paste-mode markers (ESC[200~ ... ESC[201~) that
# leak into the file as literal `[200~<key>[201~` and break auth. Use a
# non-interactive editor instead:
#     printf 'ANTHROPIC_API_KEY=sk-...\n' >> /home/core/.hermes/.env
#     # or: nano /home/core/.hermes/.env  (nano strips the markers)
set -euo pipefail

API_SERVER_KEY=$(openssl rand -hex 32)

# Resolve the workspace directory relative to this script so it works no
# matter where it's invoked from. The repo is deployed to
# /home/core/.podman/stacktek/ on the AMI.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

(cat << EOF
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GOOGLE_API_KEY=
HERMES_DASHBOARD=1
API_SERVER_ENABLED=true
API_SERVER_KEY=${API_SERVER_KEY}
TELEGRAM_BOT_TOKEN=
DISCORD_BOT_TOKEN=
EOF
) > "${SCRIPT_DIR}/.env"

mkdir -p /home/core/.hermes
cp "${SCRIPT_DIR}/.env" /home/core/.hermes/.env
chmod 600 /home/core/.hermes/.env "${SCRIPT_DIR}/.env"
cd "${SCRIPT_DIR}"
podman-compose up -d
exit 0
