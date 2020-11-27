#!/bin/sh

ZZZ="${HLSLEEP-1}"
ZZZ="$(echo "if ($ZZZ < 1) 1 else $ZZZ" | bc -l)"

while true
do
  sleep "$ZZZ"h

  /usr/local/bin/update_sa_heinlein.sh
done
