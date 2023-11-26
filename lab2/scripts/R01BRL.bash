/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=Microtic
/ip pool 
add name=brlpool ranges=172.16.10.10-172.16.10.254 
/ip address 
add address=172.31.255.30/30 interface=ether1 network=172.31.255.28 
add address=172.16.10.1/24 interface=ether2 network=172.16.10.0 
add address=100.64.1.1/30 interface=ether3 network=100.64.1.0 
add address=100.64.0.1/30 interface=ether4 network=100.64.0.0 
/ip dhcp-client 
add disabled=no interface=ether1 
/ip route 
add distance=1 dst-address=172.16.20.0/24 gateway=100.64.0.2 
add distance=1 dst-address=172.16.30.0/24 gateway=100.64.1.2 
/system identity set name=R01.BRL 
/ip dhcp-server 
add address-pool=brlpool disabled=no interface=ether2 name=dhcpbrl 
