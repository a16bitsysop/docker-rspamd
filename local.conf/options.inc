dns {
  timeout = 5s;
  retransmits = 5;
  enable_dnssec = false;
}
control_socket = "$DBDIR/rspamd.sock mode=0600";
