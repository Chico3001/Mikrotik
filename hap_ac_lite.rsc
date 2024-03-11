# ----------------------------------------------------------------------
#	2024/01/16 by Javier Ortega
#	Basic HAP AC Lite cnofiguration script
#
#	Start with a blank device
#	Setup LAN & WiFi configuration on variables below
#	WAN is on ether1
#	LAN is on every other ports
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
#	Variables
# ----------------------------------------------------------------------
# https://www.calculator.net/ip-subnet-calculator.html
# Router has the first address
:local dhcpsrc 192.168.99.0/24;
:local dhcpdns 8.8.8.8;
:local dhcpwan "ether1";

# SSID configuration
:local wifissid2G "SSID2G";
:local wifissid5G "SSID5G";
:local wifipass "mypassword";

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------
#	Router configuration below this point
# ----------------------------------------------------------------------
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
#	Calculates operation parameters
# ----------------------------------------------------------------------
:local dhcpip      [:toip [:pick $dhcpsrc 0 [:find $dhcpsrc "/"]]]
:local dhcpprfix   [:tonum [:pick $dhcpsrc ([:find $dhcpsrc "/"] + 1) [:len $dhcpsrc]]]
:local dhcpmask    (255.255.255.255<<(32 - $dhcpprfix))
:local dhcpaddspc  (~$dhcpmask)
:local dhcpnet     ($dhcpip & $dhcpmask)
:local dhcpbrcst   ($dhcpip | $dhcpaddspc)
:local dhcprouter  (($dhcpnet + 1) - ($dhcpprfix / 31))
:local dhcpfirst   ($dhcprouter + 1)
:local dhcplast    (($dhcpbrcst - 1) + ($dhcpprfix / 31))
:local dhcptotal   ([:tonum $dhcpaddspc] + 1)
:local dhcpusable  (($dhcplast - $dhcpnet) + ($dhcpprfix / 31))

:put "       Source: $dhcpsrc"
:put "           IP: $dhcpip"
:put "Subnet Prefix: $dhcpprfix"
:put "  Subnet Mask: $dhcpmask"
:put "Address Space: $dhcpaddspc"
:put "    Total IPs: $dhcptotal"
:put "  Usable* IPs: $dhcpusable"
:put "  Network* IP: $dhcpnet"
:put "Broadcast* IP: $dhcpbrcst"
:put "   Router* IP: $dhcprouter"
:put "    First* IP: $dhcpfirst"
:put "     Last* IP: $dhcplast"


# ----------------------------------------------------------------------
#	Geeneral configuration
# ----------------------------------------------------------------------
/system identity
set name=(:put [ /system routerboard get serial-number ])
/system clock
set time-zone-name=America/Mexico_City
#/interface bridge port
/tool mac-server
set allowed-interface-list=all
/tool mac-server mac-winbox
set allowed-interface-list=all
/snmp set enabled=yes
/snmp community set name=private@comunnity 0
/snmp set contact=[/system identity get name]
/snmp set location="Change Me..."
# /ip neighbor discovery-settings
# set discover-interface-list=static

:put "-> General configuration completed"


# ------------------------------------------------------------------
#	Interface configuration
# ------------------------------------------------------------------
/interface list
add name=WAN
add name=LAN
/interface bridge
add name=bridge
/interface list member
add list=WAN interface=ether1
add list=LAN interface=bridge

:put "-> Interface configuration completed"


# ------------------------------------------------------------------
#	IP / DHCP configuration
# ------------------------------------------------------------------
/ip dhcp-client
add interface=$dhcpwan disabled=no
/ip address
add interface=bridge address=$dhcprouter network=$dhcpnet
/ip pool
add name=dchp-pool1 ranges=($dhcpfirst."-".$dhcplast);
/ip dhcp-server
add name=dhcp-server interface=bridge address-pool=dchp-pool1 disabled=no
/ip dhcp-server network
add address=($dhcpnet."/".$dhcpprfix) netmask=$dhcpprfix gateway=$dhcprouter dns-server=$dhcpdns
/ip dns static
add address=$dhcprouter name=router.local

:put "-> IP / DHCP configuration completed"


# ------------------------------------------------------------------
#	WiFi configuration
# ------------------------------------------------------------------
/interface wireless security-profiles
add name=WiFiPsw authentication-types=wpa2-psk mode=dynamic-keys wpa2-pre-shared-key=$wifipass
/interface wireless
set [ find default-name=wlan1 ] name=wlan2G mode=ap-bridge disabled=no ssid=$wifissid2G security-profile=WiFiPsw hide-ssid=no wps-mode=disabled country=mexico distance=indoors installation=indoor antenna-gain=2 frequency=auto band=2ghz-g/n channel-width=20/40mhz-XX
set [ find default-name=wlan2 ] name=wlan5G mode=ap-bridge disabled=no ssid=$wifissid5G security-profile=WiFiPsw hide-ssid=no wps-mode=disabled country=mexico distance=indoors installation=indoor antenna-gain=2 frequency=auto band=5ghz-a/n/ac channel-width=20/40/80mhz-XXXX

:put "-> WiFi configuration completed"


# ------------------------------------------------------------------
#	firewall Configuration
# ------------------------------------------------------------------
/ip firewall nat add chain=srcnat out-interface-list=WAN ipsec-policy=out,none action=masquerade comment="defconf: masquerade"
/ip firewall {
filter add chain=input action=accept connection-state=established,related,untracked comment="defconf: accept established,related,untracked"
filter add chain=input action=drop connection-state=invalid comment="defconf: drop invalid"
filter add chain=input action=accept protocol=icmp comment="defconf: accept ICMP"
filter add chain=input action=accept dst-address=127.0.0.1 comment="defconf: accept to local loopback (for CAPsMAN)"
#filter add chain=input action=drop in-interface-list=!LAN comment="defconf: drop all not coming from LAN"
filter add chain=forward action=accept ipsec-policy=in,ipsec comment="defconf: accept in ipsec policy"
filter add chain=forward action=accept ipsec-policy=out,ipsec comment="defconf: accept out ipsec policy"
filter add chain=forward action=fasttrack-connection connection-state=established,related comment="defconf: fasttrack"
filter add chain=forward action=accept connection-state=established,related,untracked comment="defconf: accept established,related, untracked"
filter add chain=forward action=drop connection-state=invalid comment="defconf: drop invalid"
filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface-list=WAN comment="defconf: drop all from WAN not DSTNATed"
}

:put "-> Firewall configuration completed"


# ------------------------------------------------------------------
#	Bridge Configuration
# ------------------------------------------------------------------
/interface bridge port
add bridge=bridge interface=ether2
add bridge=bridge interface=ether3
add bridge=bridge interface=ether4
add bridge=bridge interface=ether5
add bridge=bridge interface=wlan2G
add bridge=bridge interface=wlan5G

:put "-> Bridge configuration completed"

