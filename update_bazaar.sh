#!/bin/sh

mkdir -p /tmp/bazaar
cd /tmp/bazaar || exit 1

ZZZ="${BZSLEEP-1}"
ZZZ="$(echo "if ($ZZZ < 1) 1 else $ZZZ" | bc -l)"
url="https://bazaar.abuse.ch/export/txt/md5/full/"
LOCAL_ETAG=0

while true
do
  REMOTE_ETAG=$(wget -S --spider "$url" 2>&1 | grep ETag: | cut -d\" -f2)
  echo "Checking for new Malware Bazaar file"
  if [ "$LOCAL_ETAG" != "$REMOTE_ETAG" ]
  then
    wget -O hash.zip "$url"
    unzip hash.zip
    cp -f full_md5.txt /etc/rspamd/custom/abuse_bazaar_full.txt
    rm -rf ./*
    LOCAL_ETAG="$REMOTE_ETAG"
  else
    echo "Malware Bazaar file up to date"
  fi

  sleep "$ZZZ"h
done
