#!/bin/sh

mkdir -p /tmp/bazaar
cd /tmp/bazaar || exit 1

ZZZ="${BZSLEEP-1}"
ZZZ="$(echo "if ($ZZZ < 1) 1 else $ZZZ" | bc -l)"

while true
do
  wget -O hash.zip https://bazaar.abuse.ch/export/txt/md5/full/
  unzip hash.zip
  cp -f full_md5.txt /etc/rspamd/local.d/maps.d/abuse_bazaar_full.txt
  rm -rf ./*

  sleep "$ZZZ"h
done
