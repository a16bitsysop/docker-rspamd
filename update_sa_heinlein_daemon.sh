#!/bin/sh

while true; do
  ZZZ="${HLSLEEP-1}"
  ZZZ="$(echo "if ($ZZZ < 1) 1 else $ZZZ" | bc -l)"
  sleep "$ZZZ"h

  /usr/local/bin/update_sa_heinlein.sh
done