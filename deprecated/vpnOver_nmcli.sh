withConnectivity="none"
vpnConnectivity="false"

vpnServerName=$1


check_connectivity () {
  echo `nmcli networking connectivity check`
}
check_vpnStatus () {
  echo `nmcli | grep VPN && echo "true"`
}


waitForConnectivity () {
  while [[ $withConnectivity != "full" ]]
    do
      withConnectivity="$(check_connectivity)"
    done
}
waitForVPN () {
		while [[ $vpnConnectivity != "true" ]]
				do
						vpnConnectivity="$(check_vpnStatus)"
				done
}


