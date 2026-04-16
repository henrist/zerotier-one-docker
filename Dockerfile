FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11 AS builder

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne tag=1.16.0
ENV ZEROTIER_COMMIT=7b7d39becc4a775d33e8c0f673856fb91dea7f31

RUN apk add --no-cache build-base linux-headers

RUN set -eux; \
    wget https://github.com/zerotier/ZeroTierOne/archive/$ZEROTIER_COMMIT.zip -O /zerotier.zip; \
    unzip /zerotier.zip -d /; \
    cd /ZeroTierOne-$ZEROTIER_COMMIT; \
    make ZT_SSO_SUPPORTED=0; \
    DESTDIR=/tmp/build make install

FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

COPY --from=builder /tmp/build/usr/sbin/* /usr/sbin/

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne
ENV ZEROTIER_VERSION=1.16.0

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
