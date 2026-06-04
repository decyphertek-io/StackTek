#!/bin/bash
API_SERVER_KEY=$(openssl rand -hex 32)

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
) > /home/core/.hermes/.env

mkdir -p /home/core/.hermes
cd /opt/stacktek/workspaces/ai-agents/hermes-agent/
podman-compose up -d
exit 0