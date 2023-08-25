const { spawn } = require("child_process");

let vpnConnectionID = process.argv[2];
if (vpnConnectionID === undefined)
{ vpnConnectionID = "uk1535.nordvpn.com.tcp";
}
let routeThroughVPN = [ "nmcli", ["connection", "up", "id", vpnConnectionID, "ifname", "$$$newLiveConnection"] ];

let regex_deviceConnected     = /(?<deviceConnected>.*): connected$/;

const nmMonitor = spawn("nmcli", ["monitor"]);
let process_nmMonitorOutput =
  (data) =>
  {
	  //console.log("nmVPNManager: "+data);
	  data = data.toString().split("\n")[0];

	  let deviceConnected = data.match(regex_deviceConnected);
    
    if (deviceConnected !== null)
    { 		//console.log("nmVPNManager: isNewConnection: "+data);
	    	
	        deviceConnected = deviceConnected.groups.deviceConnected;

	    	if (deviceConnected === "tun0") return;

	    	routeThroughVPN[1][5] = deviceConnected;
		//console.log(routeThroughVPN);
	    	console.log("nmVPNEnforcer: pushing device: "+deviceConnected+" through "+vpnConnectionID);
		spawn(...routeThroughVPN);
    }
  }
nmMonitor.stdout.on("data", process_nmMonitorOutput);
nmMonitor.stderr.on("data", process_nmMonitorOutput);

