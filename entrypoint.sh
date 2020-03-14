#!/bin/sh
#display environment variables passed with --env
echo "Starting rspamd at $(date +'%x %X')"
echo '$REDIS=' $REDIS
echo '$CLAMAV=' $CLAMAV
echo '$OLEFY=' $OLEFY
echo '$DCCIFD=' $DCCIFD
echo '$CONTROLIP=' $CONTROLIP
echo '$DNSSEC=' $DNSSEC
echo '$NOGREY=' $NOGREY

cd /etc/rspamd/local.d
if [ -n "$REDIS" ]; then
echo "write_servers = \"$REDIS\";
read_servers  = \"$REDIS\";
" > redis.conf
fi

if [ -n "$CLAMAV" ]; then
echo "clamav {
log_clean = true;
symbol = "CLAM_VIRUS";
type = "clamav";
servers = \"$CLAMAV:3310\";
patterns {
    # symbol_name = "pattern";
    JUST_EICAR = '^Eicar-Test-Signature$';
  }
}
" > antivirus.conf
fi

echo "#local.d/external_services.conf" > external_services.conf

if [ -n "$DCCIFD" ]; then
echo "dcc {
servers = \"$DCCIFD:10045\";
}
" >> external_services.conf
fi

if [ -n "$OLEFY" ]; then
echo "oletools {
   type = \"oletools\";
#   scan_mime_parts = \"true\";
  # default olefy settings
  servers = \"$OLEFY:10050\"
  # mime-part regex matching in content-type or filename
  mime_parts_filter_regex {
    #UNKNOWN = \"application\\/octet-stream\";
    DOC2 = \"application\\/msword\";
    DOC3 = \"application\\/vnd\.ms-word.*\";
    XLS = \"application\\/vnd\.ms-excel.*\";
    PPT = \"application\\/vnd\.ms-powerpoint.*\";
    GENERIC = \"application\\/vnd\.openxmlformats-officedocument.*\"
}
  # mime-part filename extension matching (no regex)
  mime_parts_filter_ext {
    doc = \"doc\";
    dot = \"dot\";
    docx = \"docx\";
    dotx = \"dotx\";
    docm = \"docm\";
    dotm = \"dotm\";
    xls = \"xls\";
    xlt = \"xlt\";
    xla = \"xla\";
    xlsx = \"xlsx\";
    xltx = \"xltx\";
    xlsm = \"xlsm\";
    xltm = \"xltm\";
  }
}
" >> external_services.conf
fi

[ -n "$CONTROLIP" ] && echo "secure_ip = \"$CONTROLIP\";" >> worker-controller.inc

echo "dns {
  timeout = 5s;
  retransmits = 5;" > options.inc
[ -n "$DNSSEC" ] && echo "  enable_dnssec = true;" >> options.inc
echo "}" >> options.inc
echo 'control_socket = "$DBDIR/rspamd.sock mode=0600";' >> options.inc

[ -n "$NOGREY" ] && echo "enabled = false;" > greylist.conf

[ -f /usr/sbin/rspamd ] && s="s"
/usr/"$s"bin/rspamd -f -u rspamd -g rspamd
