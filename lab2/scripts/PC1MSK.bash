/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=Microtic
/ip address
add address=172.31.255.30/30 interface=ether1 network=172.31.255.28
/ip dhcp-client
add disabled=no interface=ether1
add disabled=no interface=ether2
/ip route
add distance=1 dst-address=100.64.0.0/30 gateway=172.16.20.1
add distance=1 dst-address=100.64.3.0/30 gateway=172.16.20.1
add distance=1 dst-address=172.16.10.0/24 gateway=172.16.20.1
add distance=1 dst-address=172.16.30.0/24 gateway=172.16.20.1
/system identity set name=PC1.MSK