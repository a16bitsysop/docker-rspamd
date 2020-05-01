#!/bin/sh
#display environment variables passed with --env
echo '$REDIS=' $REDIS
echo '$CLAMAV=' $CLAMAV
echo '$OLEFY=' $OLEFY
echo '$RAZORFY=' $RAZORFY
echo '$DCCIFD=' $DCCIFD
echo '$CONTROLIP=' $CONTROLIP
echo '$DNSSEC=' $DNSSEC
echo '$NOGREY=' $NOGREY
echo '$TIMEZONE=' $TIMEZONE
echo

wait_port() {
  TL=0
  [ -n "$4" ] && INC="$4" || INC="3"
  echo "Waiting for $1"
  while :
  do
    nc -zv "$2" "$3" && return
    echo "."
    TL=`expr "$TL" + "$INC"`
    [ "$TL" -gt 90 ] && return 1
    sleep "$INC"
  done
}

if [ -n "$TIMEZONE" ]
then
  echo "Waiting for DNS"
  ping -c1 -W60 google.com || ping -c1 -W60 www.google.com
  apk add --no-cache tzdata
  if [ -f /usr/share/zoneinfo/"$TIMEZONE" ]
  then
    echo "Setting timezone to $TIMEZONE"
    cp /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
  else
    echo "$TIMEZONE does not exist"
  fi
  apk del tzdata
fi

echo "Starting rspamd at $(date +'%x %X')"
chown rspamd:rspamd /var/lib/rspamd
cd /etc/rspamd/local.d
chown rspamd:rspamd maps.d

echo "Checking for new map files"
cd maps.orig
MAPS=$(find -name '*.map')
cd ..

for m in $MAPS;
do
  echo "Checking $m"
  if [ ! -f maps.d/"$m" ]
  then
    echo "Copying $m into maps.d"
    cp -a maps.orig/"$m" maps.d/"$m"
  else
    echo "Skipping $m, already in maps.d"
  fi
done

rm -f {redis,antivirus,external_services}.conf

if [ -n "$REDIS" ]
then
  cp ../local.orig/redis.conf ./
  sed -r "s+(^(read|write)_servers).*+\1 = \"$REDIS\";+g" -i redis.conf
fi

if [ -n "$CLAMAV" ]
then
  cp ../local.orig/antivirus.conf ./
  sed -r "s+(^servers).*+\1 = \"$CLAMAV:3310\";+g" -i antivirus.conf
  wait_port "clamav" "$CLAMAV" 3310 10
fi

if [ -n "$DCCIFD" ]
then
  echo -e "dcc {\nservers = \"$DCCIFD:10045\";\n}" >> external_services.conf
  wait_port "dccifd" "$DCCIFD" 10045
fi

if [ -n "$OLEFY" ]
then
  echo -e "oletools {\n   type = \"oletools\";\n  servers = \"$OLEFY:10050\"\n}" >> external_services.conf
  wait_port "olefy" "$OLEFY" 10050
fi

if [ -n "$RAZORFY" ]
then
  echo -e "razor {\nservers = \"$RAZORFY:11342\";\n}" >> external_services.conf
  wait_port "razorfy" "$RAZORFY" 11342
fi

echo -e "bind_socket = \"*:11334\";" > worker-controller.inc
[ -n "$CONTROLIP" ] && echo -e "secure_ip = \"$CONTROLIP\";" >> worker-controller.inc

[ -n "$DNSSEC" ] && SUB=true || SUB=false
sed -r "s+(.*enable_dnssec).*+\1 = $SUB;+g" -i options.inc

[ -n "$NOGREY" ] && SUB="false" || SUB="true"
echo "enabled = $SUB;" > greylist.conf

[ -f /usr/sbin/rspamd ] && s="s"

/usr/"$s"bin/rspamd -f -u rspamd -g rspamd
