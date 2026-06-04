# StackTek

Secure browser-native workspace platform. Launch web desktops, AI agents, and containerized apps — all accessible through your browser over TLS with no VPN required.

> **This project is under active dev. Many features are still being implemented, many features are not working, and it may break.**

## Overview

StackTek makes it simple to access fully isolated web desktops, AI agents, and Linux applications directly from your browser — no VPN, no SSH, no client software required.

Each workspace is a container that spins up on demand. Web desktops stream a full Linux desktop (XFCE) to your browser over VNC with WebRTC audio. AI agents run as persistent services accessible over HTTPS. Linux applications launch in a minimal windowed environment and display directly in the browser tab — just like a remote desktop but containerized and disposable.

Everything is secured behind TLS with a Caddy + Coraza WAF edge proxy enforcing the OWASP Core Rule Set. Sessions are authenticated and isolated — each user gets their own container instance with persistent data that survives restarts. Containers are built fresh on each launch from the workspace definitions in this repo, so the environment is always clean and reproducible.

Under the hood, StackTek runs on Fedora CoreOS on AWS using rootless Podman, keeping the attack surface minimal and the host OS immutable.

## Workspaces

| Category | Examples |
|---|---|
| Web Desktops | Debian, Kali, Ubuntu, Rocky, Arch, ParrotSec (XFCE + TigerVNC) |
| AI Agents | OpenClaw, Flowise, OpenFang, Zero Agent |
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

podman-compose -f compose.yml up -d
```

The following directories are created automatically by the clone and used as bind mounts at runtime:

- `data/sessions/` — persistent session data
- `caddy/` — Caddy config and runtime data
- `certs/` — TLS certificate (generated above)

## Known Issues

> **Status: Active Development — expect bugs and breaking changes.**

| Issue | Status |
|---|---|
| WebRTC audio in web desktops | Not working |
| AI agent workspaces | Untested |
| App workspaces (single-app containers) | Untested |

## License

PolyForm Noncommercial License 1.0.0 — see [LICENSE](LICENSE).

The compiled StackTek binary and container image are proprietary and covered by the PolyForm Noncommercial License above. You are free to use, self-host, and explore StackTek for personal use, tinkering, research, and education — commercial use or resale is not permitted. All other components in this repository (workspace Containerfiles, compose files, and third-party software configurations) retain their original open source licenses as distributed by their respective upstream projects.

## Required Notice

Copyright Decyphertek LLC (https://decyphertek.io)
