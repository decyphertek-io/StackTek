# StackTek runtime image — single entry point for the whole platform.
#
# The Rust binary is built upstream in ansible-build GitHub Actions as a
# fully-static musl binary. The build-images workflow stages it into the
# build context before calling docker build.
#
# StackTek talks to the host's podman daemon over the mounted /run/podman.sock
# using the Docker-compatible REST API (bollard) — no shell-outs, no podman
# CLI in the image. That keeps the runtime base on cgr.dev/chainguard/static
# (no shell, no package manager, nothing to exploit).
#
# Build context expects:
#   ./stacktek   (the static musl binary, staged by CI)
#   ./static/    (SPA assets: index.html, app.js, style.css, novnc/...)

FROM cgr.dev/chainguard/static:latest

LABEL org.opencontainers.image.title="StackTek" \
      org.opencontainers.image.licenses="LicenseRef-PolyForm-Noncommercial-1.0"

ENV STACKTEK_BIND=0.0.0.0:8443 \
    STACKTEK_WORKSPACES=/workspaces \
    STACKTEK_DATA=/data \
    STACKTEK_STATIC=/static \
    STACKTEK_TLS_CERT=/certs/cert.pem \
    STACKTEK_TLS_KEY=/certs/key.pem \
    CONTAINER_HOST=unix:///run/podman.sock

COPY stacktek    /stacktek
COPY static/     /static/

EXPOSE 8443
# Run as uid 0 inside the container — in rootless podman this maps to the
# host's `core` user (uid 1000), which OWNS /run/user/1000/podman/podman.sock.
USER 0:0
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["/stacktek", "healthcheck"]
ENTRYPOINT ["/stacktek"]
