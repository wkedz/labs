#!/bin/bash

# Add vagrant user to group
sudo usermod -aG consul vagrant

if [ "$(hostname)" == "node1" ]; then
  export IP_BIND=\"192.168.100.111\"
  export IP_CLIENT=\"192.168.100.111\"
  export IP_ADVERTISE=\"192.168.100.111\"
  export IP_CONSUL_SERVERS='\"192.168.100.112\", \"192.168.100.113\"'
elif [ "$(hostname)" == "node2" ]; then
  export IP_BIND=\"192.168.100.112\"
  export IP_CLIENT=\"192.168.100.112\"
  export IP_ADVERTISE=\"192.168.100.112\"
  export IP_CONSUL_SERVERS='\"192.168.100.113\", \"192.168.100.111\"'
elif [ "$(hostname)" == "node3" ]; then
  export IP_BIND=\"192.168.100.113\"
  export IP_CLIENT=\"192.168.100.113\"
  export IP_ADVERTISE=\"192.168.100.113\"
  export IP_CONSUL_SERVERS='\"192.168.100.111\", \"192.168.100.112\"'
else
  exit 1
fi

# Save old config and move new one
sed  s"/IP_CONSUL_SERVERS/${IP_CONSUL_SERVERS}/g" consul.tmp.hcl > consul.hcl
sed -i s"/IP_BIND/${IP_BIND}/g" consul.hcl 
sed -i s"/IP_CLIENT/${IP_CLIENT}/g" consul.hcl 
sed -i s"/IP_ADVERTISE/${IP_ADVERTISE}/g" consul.hcl 

# Save old config and move new one
sudo mv /etc/consul.d/consul.hcl /etc/consul.d/consul.org.hcl || echo $?
sudo cp consul.hcl /etc/consul.d/consul.hcl || echo $?
sudo chown consul:consul /etc/consul.d/consul.hcl || echo $?

# Create consul data dir
sudo mkdir -p /opt/consul || echo $?
sudo chmod 775 /opt/consul || echo $?
