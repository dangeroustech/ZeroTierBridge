FROM debian:12.6 as stage
ARG PACKAGE_BASEURL=https://download.zerotier.com/debian/bookworm/pool/main/z/zerotier-one
ARG TARGETARCH
ARG VERSION=1.12.2
RUN apt-get update -qq && apt-get install -qq --no-install-recommends -y \
    ca-certificates=20230311+deb12u1 \
    curl=7.88.1-10+deb12u14
RUN ARCH_MAPPING=$([ "$TARGETARCH" = "amd64" ] && echo amd64 || ([ "$TARGETARCH" = "arm64" ] && echo arm64 || echo "$TARGETARCH")) \
    && curl -sSL -o zerotier-one.deb "${PACKAGE_BASEURL}/zerotier-one_${VERSION}_${ARCH_MAPPING}.deb"

FROM debian:12.6
ARG VERSION
RUN mkdir /app
WORKDIR /app
COPY --from=stage zerotier-one.deb .
RUN apt-get update -qq && apt-get install -qq --no-install-recommends -y \
    procps=2:4.0.2-3 \
    iptables=1.8.9-2 \
    openssl=3.0.17-1~deb12u3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN dpkg -i zerotier-one.deb && rm -f zerotier-one.deb
RUN echo "${VERSION}" >/etc/zerotier-version
COPY entrypoint.sh entrypoint.sh
RUN chmod 755 entrypoint.sh
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD sh -c 'zerotier-cli info 2>/dev/null | grep -q ONLINE'
ENTRYPOINT ["/app/entrypoint.sh"]