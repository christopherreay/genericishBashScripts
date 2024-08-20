#!/bin/bash

# Global Variables
DEFAULT_WEB_URL="www.google.com"
serverName="uninitialised"
vpnServerIP="uninitialised"
percentRegex="[0-9]+%"
countryName=""

# Function Definitions

## Check Connection State
# Check Connection State
checkConnectionState() {
  ip=$(sudo iptables -L -v -n | awk '/ens33/ && $8 ~ /^[^192\.168\.]/ && $8 !~ /^0\.0\.0\.0/ {print $8}' | uniq)
  : ${ip:="$DEFAULT_WEB_URL"}
  
  if ping -c 1 "$ip" >/dev/null 2>&1; then
    if [ "$ip" == "$DEFAULT_WEB_URL" ]; then
      echo "webUpNotVpn"
    else
      if ping -c 1 "$DEFAULT_WEB_URL" >/dev/null 2>&1; then
        echo "vpnUpAndConnected"
      else
        echo "webUpNotVpn"
      fi
    fi
  else
    echo "webDown"
  fi
}

# Robust VPN Check
robustVPNCheck() {
  while [ "$(checkConnectionState)" == "vpnUpAndConnected" ] ; do
    vpnServerIP=$(sudo iptables -L -v -n | awk '/ens33/ && $8 ~ /^[^192\.168\.]/ && $8 !~ /^0\.0\.0\.0/ {print $8}' | uniq)
    pingOutput=$(ping -q -c 16 -w 24 "$vpnServerIP")
    pingExitCode=$?
    
    echo "before regex: $pingOutput"
    packetLoss=$(echo "$pingOutput" | grep -oEi "$percentRegex")
    echo "ping packet loss: $packetLoss"

    if [ "$pingExitCode" -ne 0 ] || [ "$packetLoss" == '100%' ]; then
      echo "pingExitCode=$pingExitCode"
      break
    fi

    echoState
  done
}

echoState () {
  echo '{ "date": "'$(date)'", "openPynLoop": { "serverName": "'$serverName'", "connectionState":"'$connectionState'", "ip": "'$vpnServerIP'" } }'
}


## Parse Options
parseOptions() {
  while getopts ":s:c:" opt; do
    case ${opt} in
      s )
        serverName="-s ${OPTARG}"
        ;;
      c )
        countryName=${OPTARG}
        ;;
      \? ) 
        echo "Usage: cmd [-s] [-c]"
        ;;
    esac
  done
}

## Get Server Name
getServerName() {
  if [[ "$serverName" == "uninitialised" ]]; then
    if [[ -n "$countryName" ]]; then
      serverName="-s `/home/christopher/Scripts/nordvpn.recommended.byCountry $countryName`"
    else
      serverName="-s `/home/christopher/Scripts/nordvpn.recommended.byCountry`"
    fi
  fi
}

## Wait for Web Up
waitForWebUp() {
  sudo killall -9 openpyn
  sudo killall -9 openvpn

  while [[ $(checkConnectionState) == "webDown" ]]; do
      echo "Waiting for web to be up..."
      sleep 1
  done
  
}

## Connect to VPN
connectToVpn() {
  sudo openpyn $serverName --tcp --double -f &
}

# ## Wait for VPN Connection
# waitForVpnConnection() {
#   while [[ $(checkConnectionState) == "webUpNotVpn" ]]; do
#     vpnServerIP=$(sudo iptables -L -v -n | awk '/ens33/ && $8 ~ /^[^192\.168\.]/ && $8 !~ /^0\.0\.0\.0/ {print $8}' | uniq)
#     sleep 5
#   done
# }
## Wait for VPN Connection
waitForVpnConnection() {
  start_time=$(date +%s)
  while true; do
    connectionState=$(checkConnectionState)
    if [[ "$connectionState" == "vpnUpAndConnected" ]]; then
      echo "VPN is up and connected."
      return 0
    fi

    # Check if 40 seconds have passed
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    if [ $elapsed_time -ge 40 ]; then
      echo "Timed out waiting for VPN connection."
      return 1
    fi

    sleep 5
  done
}

# Cleanup and Exit
ctrl_c() {
  echo "CTRL+C pressed. Exiting VPN..."
  sudo openpyn -x
  exit 1
}
trap ctrl_c INT

# Main Logic

## Initial State
parseOptions "$@"
waitForWebUp
getServerName

## Main Loop
while true; do

  connectionState=$(checkConnectionState)
  echoState
  
  case $connectionState in
    "webDown")
      waitForWebUp
      ;;
    "webUpNotVpn")
      connectToVpn      
      waitForVpnConnection
      ;;
    "vpnUpAndConnected")
      robustVPNCheck
      ;;
  esac
done
