FROM alpine:3.15@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne
ENV ZEROTIER_VERSION=1.10.1

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne tag=1.10.1
ENV ZEROTIER_COMMIT=651f45fe29155c462f4e56dd74f4a347f6861d0d

RUN set -eux; \
    apk add --no-cache \
      libgcc \
      libstdc++ \
    ; \
    apk add --no-cache --virtual build-dependencies \
      build-base \
      linux-headers \
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
