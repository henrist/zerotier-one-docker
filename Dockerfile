FROM alpine:3.16@sha256:4ff3ca91275773af45cb4b0834e12b7eb47d1c18f770a0b151381cd227f4c253 as builder

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne tag=1.10.1
ENV ZEROTIER_COMMIT=651f45fe29155c462f4e56dd74f4a347f6861d0d

RUN apk add --no-cache build-base linux-headers

RUN set -eux; \
    wget https://github.com/zerotier/ZeroTierOne/archive/$ZEROTIER_COMMIT.zip -O /zerotier.zip; \
    unzip /zerotier.zip -d /; \
    cd /ZeroTierOne-$ZEROTIER_COMMIT; \
    make ZT_SSO_SUPPORTED=0; \
    DESTDIR=/tmp/build make install

FROM alpine:3.16@sha256:4ff3ca91275773af45cb4b0834e12b7eb47d1c18f770a0b151381cd227f4c253

COPY --from=builder /tmp/build/usr/sbin/* /usr/sbin/

# renovate: datasource=github-tags depName=zerotier/ZeroTierOne
ENV ZEROTIER_VERSION=1.10.1

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
