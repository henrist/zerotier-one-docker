FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS builder

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne tag=1.16.2
ENV ZEROTIER_COMMIT=fc5c3ec22090b5b2a0f274e863651fe9ca489bf4

RUN apk add --no-cache build-base linux-headers

RUN set -eux; \
    wget https://github.com/zerotier/ZeroTierOne/archive/$ZEROTIER_COMMIT.zip -O /zerotier.zip; \
    unzip /zerotier.zip -d /; \
    cd /ZeroTierOne-$ZEROTIER_COMMIT; \
    make ZT_SSO_SUPPORTED=0; \
    DESTDIR=/tmp/build make install

FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

COPY --from=builder /tmp/build/usr/sbin/* /usr/sbin/

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne
ENV ZEROTIER_VERSION=1.16.2

RUN set -eux; \
    apk add --no-cache libc6-compat libstdc++; \
    mkdir /var/lib/zerotier-one; \
    zerotier-one -v; \
    if [ "$(zerotier-one -v)" != "$ZEROTIER_VERSION" ]; then \
      >&2 echo "FATAL: unexpected version - expected $ZEROTIER_VERSION"; \
      exit 1; \
    fi

COPY entrypoint.sh /entrypoint.sh

VOLUME ["/var/lib/zerotier-one"]
ENTRYPOINT ["/entrypoint.sh"]
