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
USER 0:0
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["/stacktek", "healthcheck"]
ENTRYPOINT ["/stacktek"]
