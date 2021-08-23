#!/usr/bin/env bash 

# Load common variables
source ./start_common.sh

./deps/lgw/platform-rpi/reset_lgw.sh start $GW_RESET_PIN
# Change to project folder
cd examples/corecell

# Setup TC files from environment
echo "$TC_URI" > ./lns-ttn/tc.uri
echo "$TC_TRUST" > ./lns-ttn/tc.trust
if [ ! -z ${TC_KEY} ]; then
	echo "Authorization: Bearer $TC_KEY" | perl -p -e 's/\r\n|\n|\r/\r\n/g'  > ./lns-ttn/tc.key
fi

# Set other environment variables
export GW_RESET_GPIO=$GW_RESET_GPIO

./start-station.sh -l ./lns-ttn
