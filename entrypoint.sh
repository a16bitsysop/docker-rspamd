#!/bin/sh
#display environment variables passed with --env
echo "Starting rspamd at $(date +'%x %X')"
echo '$REDIS=' $REDIS
echo '$CLAMAV=' $CLAMAV
echo '$OLEFY=' $OLEFY
echo '$RAZORFY=' $RAZORFY
echo '$DCCIFD=' $DCCIFD
echo '$CONTROLIP=' $CONTROLIP
echo '$DNSSEC=' $DNSSEC
echo '$NOGREY=' $NOGREY

chown rspamd:rspamd /var/lib/rspamd
cd /etc/rspamd/local.d
chown rspamd:rspamd maps.d

rm -f {redis,antivirus,external_services}.conf

if [ -n "$REDIS" ]; then
cp ../local.orig/redis.conf ./
sed -r "s+(^(read|write)_servers).*+\1 = \"$REDIS\";+g" -i redis.conf
fi

if [ -n "$CLAMAV" ]; then
cp ../local.orig/antivirus.conf ./
sed -r "s+(^servers).*+\1 = \"$CLAMAV:3310\";+g" -i antivirus.conf
fi

if [ -n "$DCCIFD" ]; then
echo -e "dcc {\nservers = \"$DCCIFD:10045\";\n}" >> external_services.conf
fi

if [ -n "$OLEFY" ]; then
echo -e "oletools {\n   type = \"oletools\";\n  servers = \"$OLEFY:10050\"\n}" >> external_services.conf
fi

if [ -n "$RAZORFY" ]; then
echo -e "razor {\nservers = \"$RAZORFY:11342\";\n}" >> external_services.conf
fi

[ -n "$CONTROLIP" ] && echo -e "bind_socket = \"*:11334\";\nsecure_ip = \"$CONTROLIP\";" > worker-controller.inc

[ -n "$DNSSEC" ] && SUB=true || SUB=false
sed -r "s+(.*enable_dnssec).*+\1 = $SUB;+g" -i options.inc

[ -n "$NOGREY" ] && SUB="false" || SUB="true"
echo "enabled = $SUB;" > greylist.conf

[ -f /usr/sbin/rspamd ] && s="s"
/usr/"$s"bin/rspamd -f -u rspamd -g rspamd
