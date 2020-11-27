#!/bin/sh

# Inspired by https://github.com/mailcow/mailcow-dockerized/blob/master/data/Dockerfiles/dovecot/sa-rules.sh

set -e

# Create temp directories
[ ! -d /tmp/sa-rules-heinlein ] && mkdir -p /tmp/sa-rules-heinlein

echo "Checking for new heinlein rules"
# Read etag for current SA rules
if [ ! -f /etc/rspamd/custom/etag ]
then
  ETAG_SA_RULES=0
else
  ETAG_SA_RULES=$(cat /etc/rspamd/custom/etag)
fi

# Deploy
b_url="1.4.3.spamassassin.heinlein-support.de"
url="http://www.spamassassin.heinlein-support.de/$(drill $b_url txt | grep ^$b_url | cut -d\" -f2).tar.gz"
REMOTE_ETAG=$(wget -S --spider "$url" 2>&1 | grep ETag: | cut -d\" -f2)

if [ "$ETAG_SA_RULES" != "$REMOTE_ETAG" ]
then
  echo "Updating from $url"
  echo "$REMOTE_ETAG" > /etc/rspamd/custom/etag
  wget "$url" -O /tmp/sa-rules-heinlein.tar.gz
  if gzip -t /tmp/sa-rules-heinlein.tar.gz
  then
    tar xfvz /tmp/sa-rules-heinlein.tar.gz -C /tmp/sa-rules-heinlein
    cat /tmp/sa-rules-heinlein/*cf > /etc/rspamd/custom/sa-rules
  fi

  sed -i -e 's/\([^\\]\)\$\([^\/]\)/\1\\$\2/g' /etc/rspamd/custom/sa-rules

# restart rspamd with SIGHUP
  echo "Restarting rspamd"
  killall -SIGHUP rspamd || true

# Cleanup
  rm -rf /tmp/sa-rules-heinlein/* /tmp/sa-rules-heinlein.tar.gz

  echo "Heinlein rules updated"
else
  echo "Heinlein rules already up to date"
fi
