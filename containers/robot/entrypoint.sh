#!/bin/sh

set -e

cmd="$@"

while true; do
	status=$(curl -sSL "http://hub:4444/wd/hub/status" 2>&1 | jq -r '.value.ready' 2>&1)
	echo -n "Status: $status - "

	if $(echo $status | grep "true"); then
		echo "Selenium Grid is up"
		break
	else
		echo "Waiting for Selenium Grid"
	fi
done

exec $cmd
