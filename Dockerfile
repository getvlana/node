# A Vlana node in one container: Xray + the node agent. The agent itself is downloaded from
# your control plane at start, so it's always the exact file `verify` checks against the repo.
FROM debian:bookworm-slim
ARG XRAY_VERSION=26.3.27
RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends python3 curl unzip ca-certificates procps openssl >/dev/null \
 && arch="$(dpkg --print-architecture)" && case "$arch" in amd64) z=64;; arm64) z=arm64-v8a;; *) echo "unsupported $arch"; exit 1;; esac \
 && curl -fsSL -o /tmp/x.zip "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-${z}.zip" \
 && unzip -q /tmp/x.zip -d /usr/local/bin xray geoip.dat geosite.dat && rm /tmp/x.zip \
 && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh restart-xray.sh /usr/local/bin/
VOLUME /etc/vlana
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
