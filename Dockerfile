FROM alpine:3.16@sha256:4ff3ca91275773af45cb4b0834e12b7eb47d1c18f770a0b151381cd227f4c253

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne
ENV ZEROTIER_VERSION=1.8.4

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne tag=1.8.4
ENV ZEROTIER_COMMIT=eac56a2e25bbd27f77505cbd0c21b86abdfbd36b

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
