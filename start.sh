#!/usr/bin/env bash
script_full_path=$(dirname "$0")


source $script_full_path/env.vars

TAG_KEY="EUI"
TTN_EUI=$(cat /sys/class/net/eth0/address | sed -r 's/[:]+//g' | sed -e 's#\(.\{6\}\)\(.*\)#\1fffe\2#g')

echo "Gateway EUI: $TTN_EUI"

if [ -z ${MODEL} ] ;
 then
    echo -e "\033[91mWARNING: MODEL variable not set.\n Set the model of the gateway you are using (SX1301 or SX1302).\033[0m"
 else
    echo "Using MODEL: $MODEL"
    if [ "$MODEL" = "SX1301" ] || [ "$MODEL" = "RAK2245" ] || [ "$MODEL" = "iC880a" ];then
        $script_full_path/start_sx1301.sh
    fi
    if [ "$MODEL" = "SX1302" ] || [ "$MODEL" = "RAK2287" ];then
        $script_full_path/start_sx1302.sh
    fi
fi
