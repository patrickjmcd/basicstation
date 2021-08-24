#!/usr/bin/env bash 
script_full_path=$(dirname "$0")


# Load common variables
source $script_full_path/start_common.sh

# ./deps/lgw/platform-rpi/reset_lgw.sh start $GW_RESET_PIN
# Change to project folder
# cd examples/corecell

# Setup TC files from environment
echo "$TC_URI" > $script_full_path/lns-ttn/tc.uri
echo "$TC_TRUST" > $script_full_path/lns-ttn/tc.trust
if [ ! -z ${TC_KEY} ]; then
	echo "Authorization: Bearer $TC_KEY" | perl -p -e 's/\r\n|\n|\r/\r\n/g'  > $script_full_path/lns-ttn/tc.key
fi

# Set other environment variables
export GW_RESET_GPIO=$GW_RESET_GPIO

$script_full_path/reset_lgw.sh start
$script_full_path/build-corecell-std/bin/station -f -h $script_full_path/lns-ttn
