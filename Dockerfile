FROM alpine:3.11
LABEL maintainer "Duncan Bellamy <dunk@denkimushi.com>"

RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories && \
apk add --no-cache rspamd rspamd-fuzzy rspamd-controller rspamd-proxy && \
wget -O /usr/share/rspamd/plugins/phishing.lua https://raw.githubusercontent.com/rspamd/rspamd/f294479f789d43eda71d330a81af8bb2fd147603/src/plugins/lua/phishing.lua

WORKDIR /usr/local/bin
COPY entrypoint.sh ./

WORKDIR /etc/rspamd/local.d/maps.d
COPY --chown=rspamd:rspamd maps/* ./

WORKDIR /etc/rspamd/local.d
COPY local.conf ./

CMD [ "entrypoint.sh" ]

VOLUME [ "/var/lib/rspamd" "/etc/rspamd/override.d" "/etc/rspamd/local.d/maps.d" ]
EXPOSE 11332 11334
