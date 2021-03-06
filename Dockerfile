FROM alpine:3.14
LABEL maintainer="Duncan Bellamy <dunk@denkimushi.com>"

ENV dqsver master

# hadolint ignore=DL3018
RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories \
&& apk add --no-cache --upgrade rspamd rspamd-fuzzy rspamd-controller rspamd-proxy drill stunnel \
&& mkdir /run/rspamd && chown rspamd:rspamd /run/rspamd \
&& mkdir /run/stunnel && chown stunnel:stunnel /run/stunnel

WORKDIR /tmp
RUN wget -q https://github.com/spamhaus/rspamd-dqs/archive/${dqsver}.tar.gz \
&& tar -xzf ${dqsver}.tar.gz \
&& mv rspamd-dqs-${dqsver}/2.x /etc/rspamd/rspamd-dqs \
&& rm -Rf ./*

WORKDIR /usr/local/bin
COPY travis-helpers/set-timezone.sh entrypoint.sh update_bazaar.sh update_sa_heinlein.sh update_sa_heinlein_daemon.sh ./

WORKDIR /etc/rspamd/local.d
COPY local.conf ./

WORKDIR /etc/rspamd/local.d/maps.orig
COPY --chown=rspamd:rspamd maps/* ./

COPY stunnel.conf /etc/stunnel/stunnel.conf

CMD [ "entrypoint.sh" ]
VOLUME /var/lib/rspamd /etc/rspamd/override.d /etc/rspamd/local.d/maps.d
EXPOSE 11332 11334
