FROM alpine:3.8

ENV ZEROTIER_VERSION=1.2.12

RUN set -eux; \
    apk add --no-cache \
      libgcc \
      libstdc++ \
    ; \
    apk add --no-cache --virtual build-dependencies \
      build-base \
      linux-headers \
    ; \
    wget https://github.com/zerotier/ZeroTierOne/archive/$ZEROTIER_VERSION.zip -O /zerotier.zip; \
    unzip /zerotier.zip -d /; \
    cd /ZeroTierOne-$ZEROTIER_VERSION; \
    make; \
    DESTDIR=/tmp/build make install; \
    mv /tmp/build/usr/sbin/* /usr/sbin/; \
    mkdir /var/lib/zerotier-one; \
    apk del build-dependencies; \
    rm -rf /tmp/build; \
    rm -rf /ZeroTierOne-$ZEROTIER_VERSION; \
    rm -rf /zerotier.zip; \
    zerotier-one -v

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
