FROM debian:13.1 AS stage
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG PACKAGE_BASEURL=https://download.zerotier.com/debian/trixie/pool/main/z/zerotier-one
ARG TARGETARCH
ARG VERSION=1.16.0-2
RUN apt-get update -qq && apt-get install -qq --no-install-recommends -y \
    ca-certificates=20250419 \
    curl=8.14.1-2
RUN set -e; \
    DETECTED_ARCH="${TARGETARCH:-}"; \
    if [ -z "$DETECTED_ARCH" ]; then DETECTED_ARCH="$(dpkg --print-architecture)"; fi; \
    case "$DETECTED_ARCH" in \
      amd64|x86_64) ARCH_MAPPING=amd64 ;; \
      arm64|aarch64) ARCH_MAPPING=arm64 ;; \
      armhf|armv7*) ARCH_MAPPING=armhf ;; \
      *) echo "Unsupported architecture: $DETECTED_ARCH" >&2; exit 1 ;; \
    esac; \
    echo "Downloading ZeroTier: arch=$ARCH_MAPPING version=$VERSION"; \
    curl -fsSL -o zerotier-one.deb "${PACKAGE_BASEURL}/zerotier-one_${VERSION}_${ARCH_MAPPING}.deb"

FROM debian:13.1
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG VERSION
RUN mkdir /app
WORKDIR /app
COPY --from=stage zerotier-one.deb .
RUN apt-get update -qq && apt-get install -qq --no-install-recommends -y \
    adduser=3.152 \
    procps=2:4.0.4-9 \
    iptables=1.8.11-2 \
    openssl=3.5.1-1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN dpkg -i zerotier-one.deb && rm -f zerotier-one.deb
RUN echo "${VERSION}" >/etc/zerotier-version
COPY entrypoint.sh entrypoint.sh
RUN chmod 755 entrypoint.sh
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD sh -c 'zerotier-cli info 2>/dev/null | grep -q ONLINE'
ENTRYPOINT ["/app/entrypoint.sh"]