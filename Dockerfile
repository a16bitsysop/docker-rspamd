FROM alpine:3.11
LABEL maintainer "Duncan Bellamy <dunk@denkimushi.com>"

ENV pkgver 2.3
WORKDIR /tmp
RUN apk add --no-cache glib icu libmagic openssl lua5.1 pcre libsodium sqlite-libs
RUN apk add --no-cache --virtual .build-deps \
	build-base perl cmake ragel \
	glib-dev icu-dev openssl-dev lua5.1-dev pcre-dev libsodium-dev sqlite-dev
RUN addgroup -S rspamd && adduser -S -h /var/lib/rspamd --ingroup rspamd rspamd && \
wget https://github.com/vstakhov/rspamd/archive/${pkgver}.tar.gz && \
tar -xzf ${pkgver}.tar.gz && mkdir rspamd.build && cd rspamd.build && \
cmake \
                -DCMAKE_INSTALL_PREFIX=/usr \
                -DCONFDIR=/etc/rspamd \
                -DRUNDIR=/run/rspamd \
                ../rspamd-${pkgver} && \
make && make install && \
cd /tmp && rm -Rf * rspamd.build && \
apk del .build-deps && \
mkdir /etc/rspamd/override.d

WORKDIR /usr/local/bin
COPY entrypoint.sh ./

WORKDIR /etc/rspamd/local.d/maps.d
COPY --chown=rspamd:rspamd maps/* ./

WORKDIR /etc/rspamd/local.d
COPY local.conf ./

CMD [ "entrypoint.sh" ]

VOLUME [ "/var/lib/rspamd" "/etc/rspamd/override.d" "/etc/rspamd/local.d/maps.d" ]
EXPOSE 11332 11334
