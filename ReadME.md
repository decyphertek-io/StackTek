# StackTek

Secure browser-native workspace platform. Launch web desktops, AI agents, and containerized apps — all accessible through your browser over TLS with no VPN required.

## Overview

StackTek runs on Fedora CoreOS (AWS) and orchestrates containerized workspaces via rootless Podman. A Caddy + Coraza WAF edge proxy handles TLS termination and WAF protection. The StackTek orchestrator manages workspace lifecycle, VNC bridging, and web app proxying.

## Workspaces

| Category | Examples |
|---|---|
| Web Desktops | Debian, Kali, Ubuntu, Rocky, Arch, ParrotSec (XFCE + TigerVNC) |
| AI Agents | OpenClaw, Flowise, OpenFang, Zero Agent |
| Apps | Chromium, LibreOffice, VSCodium, Signal, Telegram, Thunderbird, KeePassXC |

## License

PolyForm Noncommercial License 1.0.0 — see [LICENSE](LICENSE).

The compiled StackTek binary and container image are proprietary. Workspace Containerfiles, compose files, and configuration files in this repository are provided under the license above.

## Required Notice

Copyright Decyphertek IO (https://decyphertek.io)
