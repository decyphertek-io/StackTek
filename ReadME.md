# StackTek

Secure browser-native workspace platform. Launch web desktops, AI agents, and containerized apps — all accessible through your browser over TLS with no VPN required.

> **This project is under active dev. Many features are still being implemented, many features are not working, and it may break.**

## Overview

StackTek makes it simple to access fully isolated web desktops, AI agents, and Linux applications directly from your browser — no VPN, no SSH, no client software required.

Each workspace is a container that spins up on demand. Web desktops stream a full Linux desktop (XFCE) to your browser over VNC with audio carried as raw PCM over a WebSocket (decoded by the Web Audio API). AI agents run as persistent services accessible over HTTPS. Linux applications launch in a minimal windowed environment and display directly in the browser tab — just like a remote desktop but containerized and disposable.

Everything is secured behind TLS with a Caddy + Coraza WAF edge proxy enforcing the OWASP Core Rule Set. Sessions are authenticated and isolated — each user gets their own container instance with persistent data that survives restarts. Containers are built fresh on each launch from the workspace definitions in this repo, so the environment is always clean and reproducible.

Under the hood, StackTek runs on Fedora CoreOS on AWS using rootless Podman, keeping the attack surface minimal and the host OS immutable.

## Workspaces

| Category | Workspaces |
|---|---|
| Web Desktops | Debian, Kali, Ubuntu, Rocky, Arch, ParrotSec (XFCE + TigerVNC) |
| AI Agents | OpenWebUI, Hermes, Paperclip, TradingAgents, Fincept Terminal, Space Agent, HIA, CrewAI, OpenRAG, OpenBrowser, Mike OSS, BrowserOS, Open Notebook, XFormAI, OpenClaw, Flowise, LibreChat, Agent Zero, OpenFang |
| CyberLab | Vulhub CVE Lab, WebGoat, Mutillidae, DVWA |
| Apps | Chromium, LibreOffice, VSCodium, Signal, Telegram, Thunderbird, KeePassXC |

## Quick Start

> **Note:** StackTek has only been tested with Podman. Docker Compose may work but is not officially supported.

```bash
git clone https://github.com/decyphertek-io/stacktek.git
cd stacktek
# Generate a self-signed TLS certificate (required before first run)
mkdir -p certs

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout certs/key.pem -out certs/cert.pem \
  -subj "/O=decyphertek/CN=stacktek"
chmod 0644 certs/key.pem certs/cert.pem

# If you need 443 to work on CoreOS or RedHat based Systems with SeLinux
sudo sh -c 'echo "net.ipv4.ip_unprivileged_port_start=443" >> /etc/sysctl.conf'
sudo sysctl -p /etc/sysctl.conf
# Start Stacktek
podman-compose -f compose.yml up -d

#optional cleanup

```

### Accessing StackTek

- **Locally:** https://localhost
- **Remotely:** https://IP-OF-SERVER

The following directories are created automatically by the clone and used as bind mounts at runtime:

- `data/sessions/` — persistent session data
- `caddy/` — Caddy config and runtime data
- `certs/` — TLS certificate (generated above)

## Known Issues

> **Status: Active Development — expect bugs and breaking changes.**

| Issue | Status |
|---|---|
| Desktop audio | Wired — PCM-over-WebSocket → Web Audio API. Verify the container's PipeWire null-sink + `module-simple-protocol-tcp` are running on port 4713 (`pactl list modules`) if sound is silent. |
| AI agent workspaces | Compose-based agents are wired through the in-process compose interpreter (`/apps/:id/*` reverse proxy). Containerfile-based agents use the build+run path. See per-workspace `manifest.toml` for `web_port`/`primary_service`. |
| App workspaces (single-app containers) | Wired via compose + `/apps/:id/*`. Verify the image exposes the port named in `manifest.toml::web_port`. |

### Editing `.env` files for API keys

Do **not** paste API keys into `vi` directly. Terminals emit
bracketed-paste-mode escape sequences (`ESC[200~ … ESC[201~`) that leak into
the file as literal `[200~<key>[201~` and break authentication. Use a
non-interactive editor or `printf`:

```bash
# Append a key safely:
printf 'ANTHROPIC_API_KEY=sk-ant-...\n' >> /home/core/.hermes/.env
# Or use nano, which strips the bracket markers on paste:
nano /home/core/.hermes/.env
```

### Updating StackTek on a running host

```bash
cd ~/.podman/stacktek
podman-compose down
git pull
podman-compose pull
podman-compose up -d --force-recreate
```

### Troubleshooting

```bash
# Filtered logs for known failure keywords
podman logs stacktek 2>&1 | grep -i "openclaw\|arch\|compose\|chromium\|kali\|failed\|error" | tail -50

# List all stacktek-managed containers (stopped + running)
podman ps -a --filter name=stacktek

# Inspect a workspace container's port from the stacktek bridge network
podman exec stacktek wget -qO- "http://stacktek-<workspace>:<web_port>/" || true
```

## License

PolyForm Noncommercial License 1.0.0 — see [LICENSE](LICENSE).

The compiled StackTek binary and container image are proprietary and covered by the PolyForm Noncommercial License above. You are free to use, self-host, and explore StackTek for personal use, tinkering, research, and education — commercial use or resale is not permitted. All other components in this repository (workspace Containerfiles, compose files, and third-party software configurations) retain their original open source licenses as distributed by their respective upstream projects.

## Required Notice

Copyright Decyphertek LLC (https://decyphertek.io)
