#!/bin/bash

echo -n Enter Web Interface Password:
read -s password
echo
# Run Command
hash=$(docker container run a16bitsysop/rspamd rspamadm pw -e -p $password)

echo "Add to persistant file override.d/worker-controller.inc :-

password: \"$hash\";
enable_password: \"$hash\";"
