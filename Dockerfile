FROM alpine:3.15@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne
ENV ZEROTIER_VERSION=1.8.6

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne tag=1.8.6
ENV ZEROTIER_COMMIT=4a2c75a60941e75f36ed1961458a42fbd12ea4ac

RUN set -eux; \
    apk add --no-cache \
      libgcc \
      libstdc++ \
    ; \
    apk add --no-cache --virtual build-dependencies \
      cargo \
      build-base \
      linux-headers \
      openssl-dev \
    ; \
    wget https://github.com/zerotier/ZeroTierOne/archive/$ZEROTIER_COMMIT.zip -O /zerotier.zip; \
    unzip /zerotier.zip -d /; \
    cd /ZeroTierOne-$ZEROTIER_COMMIT; \
    make; \
    DESTDIR=/tmp/build make install; \
    mv /tmp/build/usr/sbin/* /usr/sbin/; \
    mkdir /var/lib/zerotier-one; \
    apk del build-dependencies; \
    rm -rf /tmp/build; \
    rm -rf /ZeroTierOne-$ZEROTIER_COMMIT; \
    rm -rf /zerotier.zip; \
    zerotier-one -v; \
    if [ "$(zerotier-one -v)" != "$ZEROTIER_VERSION" ]; then \
      >&2 echo "FATAL: unexpected version - expected $ZEROTIER_VERSION"; \
      exit 1; \
    fi

COPY entrypoint.sh /entrypoint.sh

VOLUME ["/var/lib/zerotier-one"]
ENTRYPOINT ["/entrypoint.sh"]
