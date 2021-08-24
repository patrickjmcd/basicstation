#!/usr/bin/env bash

source /opt/basicstation/env.vars

TAG_KEY="EUI"
TTN_EUI=$(cat /sys/class/net/eth0/address | sed -r 's/[:]+//g' | sed -e 's#\(.\{6\}\)\(.*\)#\1fffe\2#g')

echo "Gateway EUI: $TTN_EUI"

if [ -z ${MODEL} ] ;
 then
    echo -e "\033[91mWARNING: MODEL variable not set.\n Set the model of the gateway you are using (SX1301 or SX1302).\033[0m"
 else
    echo "Using MODEL: $MODEL"
    if [ "$MODEL" = "SX1302" ] || [ "$MODEL" = "RAK2287" ];then

        # Load common variables
        # Defaults to TTN server v2, EU region
        TTN_STACK_VERSION=${TTN_STACK_VERSION:-3}
        if [ $TTN_STACK_VERSION -eq 2 ]; then
            TTN_REGION=${TTN_REGION:-"eu"}
            TC_URI=${TC_URI:-"wss://lns.${TTN_REGION}.thethings.network:443"} 
        elif [ $TTN_STACK_VERSION -eq 3 ]; then
            TTN_REGION=${TTN_REGION:-"eu1"}
            TC_URI=${TC_URI:-"wss://${TTN_REGION}.cloud.thethings.network:8887"} 
        else
            echo -e "\033[91mERROR: Wrong TTN_STACK_VERSION value, should be either 2 o 3.\033[0m"
        fi

        # Get certificate
        TC_TRUST=${TC_TRUST:-$(curl --silent "https://letsencrypt.org/certs/{trustid-x3-root.pem.txt,isrgrootx1.pem}")}

        # Sanitize TC_TRUST
        TC_TRUST=$(echo $TC_TRUST | sed 's/\s//g' | sed 's/-----BEGINCERTIFICATE-----/-----BEGIN CERTIFICATE-----\n/g' | sed 's/-----ENDCERTIFICATE-----/\n-----END CERTIFICATE-----\n/g' | sed 's/\n+/\n/g')

        # Check configuration
        if [ "$TC_URI" == "" ] || [ "$TC_TRUST" == "" ]
        then
            echo -e "\033[91mERROR: Missing configuration, define either TTN_STACK_VERSION or TC_URI and TC_TRUST.\033[0m"
        fi

        echo "Server: $TC_URI"

        # declare map of hardware pins to GPIO on Raspberry Pi
        declare -a pinToGPIO
        pinToGPIO=( -1 -1 -1 2 -1 3 -1 4 14 -1 15 17 18 27 -1 22 23 -1 24 10 -1 9 25 11 8 -1 7 0 1 5 -1 6 12 13 -1 19 16 26 20 -1 21)
        GW_RESET_PIN=${GW_RESET_PIN:-11}
        GW_RESET_GPIO=${GW_RESET_GPIO:-${pinToGPIO[$GW_RESET_PIN]}}
        LORAGW_SPI=${LORAGW_SPI:-"/dev/spidev0.0"}

        # Setup TC files from environment
        echo "$TC_URI" > /opt/basicstation/lns-ttn/tc.uri
        echo "$TC_TRUST" > /opt/basicstation/lns-ttn/tc.trust
        if [ ! -z ${TC_KEY} ]; then
            echo "Authorization: Bearer $TC_KEY" | perl -p -e 's/\r\n|\n|\r/\r\n/g'  > /opt/basicstation/lns-ttn/tc.key
        fi

        # Set other environment variables
        export GW_RESET_GPIO=$GW_RESET_GPIO

        /opt/basicstation/reset_lgw.sh start
        /opt/basicstation/build-corecell-std/bin/station -f -h /opt/basicstation/lns-ttn

    fi
fi
