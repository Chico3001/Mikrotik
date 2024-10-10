# ----------------------------------------------------------------------
#	2024/09/27 by Javier Ortega
#	
#	Script de configuracion de HaP AC 2 para TV Azteca
#	Crea 2 WiFi para poder probar dispositivos en ambientes controlados
#	AztecaMX	Crea una red local simple para simular un hogar
#				en Mexico
#	AztecaUSA 	Crea una red local con VPN a USA para simular un
#				hogar en USA
#	
#	Instalacion:
#	Iniciar con un dispositivo en blanco
#	Configurar las variables requeridas
#	El dispositivo se conectara a una de 2 WANs para servir en la
#	WiFi o en los puertos ethernet
#   S5NHCKCY5O
#   6PNUCVIJ73
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
#	Variables
# ----------------------------------------------------------------------
:local wanWifi            "WiFi5G";
:local wanWifiSsid        "ssid";
:local wanWifiPass        "12345678";
:local wanEthernet        "ether1";

:local lanMxWifiSsid      "ssid";
:local lanMxWifiPass      "1234567890";
:local lanMxSrc            "192.168.50.0/24";
:local lanMxdns            "8.8.8.8";

:local lanUsWifiSsid      "ssid";
:local lanUsWifiPass      "1234567890";
:local lanUsSrc           "192.168.60.0/24";
:local lanUsdns            "8.8.8.8";

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------
#	Configuracion del equipo
#	No mover nada pasando este punto
# ----------------------------------------------------------------------
# ----------------------------------------------------------------------
:local routerName         "TVADIGITAL-TEST01";
:local routerTz           "America/Mexico_City";
:local snmpEnabled        "no";
:local snmpCommunity      "private@tvadigital";
:local snmpContact        "TVA Digital Arquitectura";
:local snmpLocation       "TB 3er Piso";


# ----------------------------------------------------------------------
#	Calcula parametros de operacion
# ----------------------------------------------------------------------
:local lanMxip      [:toip [:pick $lanMxSrc 0 [:find $lanMxSrc "/"]]]
:local lanMxprfix   [:tonum [:pick $lanMxSrc ([:find $lanMxSrc "/"] + 1) [:len $lanMxSrc]]]
:local lanMxmask    (255.255.255.255<<(32 - $lanMxprfix))
:local lanMxaddspc  (~$lanMxmask)
:local lanMxnet     ($lanMxip & $lanMxmask)
:local lanMxbrcst   ($lanMxip | $lanMxaddspc)
:local lanMxrouter  (($lanMxnet + 1) - ($lanMxprfix / 31))
:local lanMxfirst   ($lanMxrouter + 1)
:local lanMxlast    (($lanMxbrcst - 1) + ($lanMxprfix / 31))
:local lanMxtotal   ([:tonum $lanMxaddspc] + 1)
:local lanMxusable  (($lanMxlast - $lanMxnet) + ($lanMxprfix / 31))

:put ""
:put "Configuracion Lan Mexico"
:put "       Source: $lanMxsrc"
:put "           IP: $lanMxip"
:put "Subnet Prefix: $lanMxprfix"
:put "  Subnet Mask: $lanMxmask"
:put "Address Space: $lanMxaddspc"
:put "    Total IPs: $lanMxtotal"
:put "  Usable* IPs: $lanMxusable"
:put "  Network* IP: $lanMxnet"
:put "Broadcast* IP: $lanMxbrcst"
:put "   Router* IP: $lanMxrouter"
:put "    First* IP: $lanMxfirst"
:put "     Last* IP: $lanMxlast"

:local lanUsip      [:toip [:pick $lanUsSrc 0 [:find $lanUsSrc "/"]]]
:local lanUsprfix   [:tonum [:pick $lanUsSrc ([:find $lanUsSrc "/"] + 1) [:len $lanUsSrc]]]
:local lanUsmask    (255.255.255.255<<(32 - $lanUsprfix))
:local lanUsaddspc  (~$lanUsmask)
:local lanUsnet     ($lanUsip & $lanUsmask)
:local lanUsbrcst   ($lanUsip | $lanUsaddspc)
:local lanUsrouter  (($lanUsnet + 1) - ($lanUsprfix / 31))
:local lanUsfirst   ($lanUsrouter + 1)
:local lanUslast    (($lanUsbrcst - 1) + ($lanUsprfix / 31))
:local lanUstotal   ([:tonum $lanUsaddspc] + 1)
:local lanUsusable  (($lanUslast - $lanUsnet) + ($lanUsprfix / 31))

:put ""
:put "Configuracion Lan USA"
:put "       Source: $lanUssrc"
:put "           IP: $lanUsip"
:put "Subnet Prefix: $lanUsprfix"
:put "  Subnet Mask: $lanUsmask"
:put "Address Space: $lanUsaddspc"
:put "    Total IPs: $lanUstotal"
:put "  Usable* IPs: $lanUsusable"
:put "  Network* IP: $lanUsnet"
:put "Broadcast* IP: $lanUsbrcst"
:put "   Router* IP: $lanUsrouter"
:put "    First* IP: $lanUsfirst"
:put "     Last* IP: $lanUslast"


# ------------------------------------------------------------------
#	Interface configuration
# ------------------------------------------------------------------
/interface wireless set [/interface find name=wlan1] name=WiFi2G disabled=no
/interface wireless set [/interface find name=wlan2] name=WiFi5G disabled=no
/interface list
add name=WAN
add name=LANMX
add name=LANUS
/interface bridge
add name=bridgemx
add name=bridgeus
/interface list member
#add list=WAN interface=ether1
add list=WAN interface=WiFi5G
add list=LANMX interface=bridgemx
add list=LANUS interface=bridgeus

:put "-> Interface configuration completed"


# ------------------------------------------------------------------
#	WiFi configuration
# ------------------------------------------------------------------
/interface wireless security-profiles
add name=WanWifiPass authentication-types=wpa2-psk mode=dynamic-keys wpa2-pre-shared-key=$wanWifiPass
#add name=MxWifiPass authentication-types=wpa2-psk mode=dynamic-keys wpa2-pre-shared-key=$lanMxWifiPass
#add name=UsWifiPass authentication-types=wpa2-psk mode=dynamic-keys wpa2-pre-shared-key=$lanUsWifiPass
/interface wireless
#set [ find name=WiFi2G ] mode=station-bridge disabled=no ssid=$wanWifiSsid security-profile=WanWifiPass hide-ssid=no wps-mode=disabled country=mexico distance=indoors installation=indoor antenna-gain=2 frequency=auto band=2ghz-b/g/n channel-width=20/40mhz-XX
set [ find name=WiFi5G ] mode=station disabled=no ssid=$wanWifiSsid security-profile=WanWifiPass hide-ssid=no wps-mode=disabled country=mexico distance=indoors installation=indoor antenna-gain=3 frequency=auto band=5ghz-a/n/ac channel-width=20/40/80mhz-XXXX
#add mode=ap-bridge master-interface=WiFi2G ssid=$lanMxWifiSsid security-profile=MxWifiPass
#add mode=ap-bridge master-interface=WiFi5G ssid=$lanMxWifiSsid security-profile=MxWifiPass
#add mode=ap-bridge master-interface=WiFi2G ssid=$lanUsWifiSsid security-profile=UsWifiPass
#add mode=ap-bridge master-interface=WiFi5G ssid=$lanUsWifiSsid security-profile=UsWifiPass

#set [ find name=WiFi2G ] mode=ap-bridge disabled=no ssid=$lanMxWifiSsid security-profile=MxWifiPass hide-ssid=no wps-mode=disabled country=mexico distance=indoors installation=indoor antenna-gain=2 frequency=auto band=2ghz-g/n channel-width=20/40mhz-XX
#set [ find name=WiFi5G ] mode=ap-bridge disabled=no ssid=$lanMxWifiSsid security-profile=MxWifiPass hide-ssid=no wps-mode=disabled country=mexico distance=indoors installation=indoor antenna-gain=2 frequency=auto band=5ghz-a/n/ac channel-width=20/40/80mhz-XXXX

:put "-> WiFi configuration completed"


# ------------------------------------------------------------------
#	IP / DHCP configuration
# ------------------------------------------------------------------
/ip dhcp-client
add interface=$wanEthernet disabled=no
add interface=$wanWifi disabled=no
/ip pool
add name=dchp-pool-mx ranges=($lanMxfirst."-".$lanMxlast);
add name=dchp-pool-us ranges=($lanUsfirst."-".$lanUslast);
/ip address
add interface=bridgemx address=($lanMxrouter."/".$lanMxprfix) network=$lanMxnet
add interface=bridgeus address=($lanUsrouter."/".$lanMxprfix) network=$lanUsnet
/ip dhcp-server
add name=dhcp-server-mx interface=bridgemx address-pool=dchp-pool-mx disabled=no
add name=dhcp-server-us interface=bridgeus address-pool=dchp-pool-us disabled=no
/ip dhcp-server network
add address=($lanMxnet."/".$lanMxprfix) netmask=$lanMxprfix gateway=$lanMxrouter dns-server=$lanMxdns
add address=($lanUsnet."/".$lanUsprfix) netmask=$lanUsprfix gateway=$lanUsrouter dns-server=$lanUsdns
/ip dns static
add address=$lanMxrouter name=routermx.local
add address=$lanUsrouter name=routerus.local

:put "-> IP / DHCP configuration completed"


# ------------------------------------------------------------------
#	firewall Configuration
# ------------------------------------------------------------------
/ip firewall nat add chain=srcnat out-interface-list=WAN ipsec-policy=out,none action=masquerade comment="defconf: masquerade"
/ip firewall {
filter add chain=input disabled=no action=accept connection-state=established,related,untracked comment="defconf: accept established,related,untracked"
filter add chain=input disabled=no action=drop connection-state=invalid comment="defconf: drop invalid"
filter add chain=input disabled=no action=accept protocol=icmp comment="defconf: accept ICMP"
filter add chain=input disabled=no action=accept dst-address=127.0.0.1 comment="defconf: accept to local loopback (for CAPsMAN)"
filter add chain=input disabled=yes  action=drop in-interface-list=!LANMX comment="defconf: drop all not coming from LAN"
filter add chain=forward action=drop connection-state=invalid comment="defconf: drop invalid"
filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface-list=WAN comment="defconf: drop all from WAN not DSTNATed"
filter add chain=forward action=drop src-address=192.168.50.0/24 dst-address=192.168.60.0/24 log=no log-prefix=""
filter add chain=forward action=drop src-address=192.168.60.0/24 dst-address=192.168.50.0/24 log=no log-prefix=""
filter add chain=forward action=accept ipsec-policy=in,ipsec comment="defconf: accept in ipsec policy"
filter add chain=forward action=accept ipsec-policy=out,ipsec comment="defconf: accept out ipsec policy"
filter add chain=forward action=fasttrack-connection connection-state=established,related comment="defconf: fasttrack"
filter add chain=forward action=accept connection-state=established,related,untracked comment="defconf: accept established,related, untracked"
}

:put "-> Firewall configuration completed"


# ------------------------------------------------------------------
#	Bridge Configuration
# ------------------------------------------------------------------
/interface bridge port
add bridge=bridgemx interface=ether2
add bridge=bridgemx interface=ether3
add bridge=bridgeus interface=ether4
add bridge=bridgeus interface=ether5
# add bridge=bridge interface=wlan2G
# add bridge=bridge interface=wlan5G

:put "-> Bridge configuration completed"


# https://support.nordvpn.com/hc/enUs/articles/20398642652561-MikroTik-IKEv2-setup-withNordVPN

