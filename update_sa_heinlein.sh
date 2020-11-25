#!/bin/sh

# Inspired by https://github.com/mailcow/mailcow-dockerized/blob/master/data/Dockerfiles/dovecot/sa-rules.sh

set -e

# Create temp directories
[ ! -d /tmp/sa-rules-heinlein ] && mkdir -p /tmp/sa-rules-heinlein

echo "Updating heinlein rules"
# Hash current SA rules
if [ ! -f /etc/rspamd/custom/sa-rules ]; then
  HASH_SA_RULES=0
else
  HASH_SA_RULES=$(md5sum /etc/rspamd/custom/sa-rules | cut -d' ' -f1)
fi

# Deploy
url="http://www.spamassassin.heinlein-support.de/$(drill 1.4.3.spamassassin.heinlein-support.de txt | grep ^1.4.3.spamassassin.heinlein-support.de | cut -d\" -f2).tar.gz"
echo "Updating from $url"
wget "$url" -O /tmp/sa-rules-heinlein.tar.gz
if gzip -t /tmp/sa-rules-heinlein.tar.gz; then
  tar xfvz /tmp/sa-rules-heinlein.tar.gz -C /tmp/sa-rules-heinlein
  cat /tmp/sa-rules-heinlein/*cf > /etc/rspamd/custom/sa-rules
fi

sed -i -e 's/\([^\\]\)\$\([^\/]\)/\1\\$\2/g' /etc/rspamd/custom/sa-rules

# restart rspamd with SIGHUP if hash changed
if [ "$(md5sum /etc/rspamd/custom/sa-rules | cut -d' ' -f1)" != "${HASH_SA_RULES}" ]; then
  echo "Restarting rspamd"
  killall -SIGHUP rspamd || true
fi

# Cleanup
rm -rf /tmp/sa-rules-heinlein /tmp/sa-rules-heinlein.tar.gz

echo "Heinlein rules updated"
