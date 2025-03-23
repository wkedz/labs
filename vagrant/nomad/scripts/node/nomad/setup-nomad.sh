#!/bin/bash

# Add vagrant user to group
sudo usermod -aG nomad  vagrant
sudo usermod -aG docker vagrant


if [ "$(hostname)" == "node1" ]; then
  export ADDR_CONSUL=\"192.168.100.111:8500\"
  export IP_HOST=\"192.168.100.111\"
  export IP_NOMAD_SERVERS='\"192.168.100.112\", \"192.168.100.113\"'
elif [ "$(hostname)" == "node2" ]; then
  export ADDR_CONSUL=\"192.168.100.112:8500\"
  export IP_HOST=\"192.168.100.112\"
  export IP_NOMAD_SERVERS='\"192.168.100.113\", \"192.168.100.111\"'
elif [ "$(hostname)" == "node3" ]; then
  export ADDR_CONSUL=\"192.168.100.113:8500\"
  export IP_HOST=\"192.168.100.113\"
  export IP_NOMAD_SERVERS='\"192.168.100.111\", \"192.168.100.112\"'
else
  exit 1
fi


# Save oild config and move new one
sudo mv /etc/nomad.d/nomad.hcl /etc/nomad.d/nomad.org.hcl || echo $?

sed  s"/SERVERS/${IP_NOMAD_SERVERS}/g" nomad.tmp.hcl > nomad.hcl
sed -i s"/IP/${IP_HOST}/g" nomad.hcl 
sed -i s"/ADDR_CONSUL/${ADDR_CONSUL}/g" nomad.hcl 

sudo cp nomad.hcl /etc/nomad.d/nomad.hcl || echo $?
sudo chown nomad:nomad /etc/nomad.d/nomad.hcl || echo $?

# Create nomad data dir
sudo mkdir -p /opt/nomad || echo $?
sudo chmod 775 /opt/nomad || echo $?

# Create nomad directories
sudo mkdir -p /opt/nomad-volumes/grafana || echo $?
sudo mkdir -p /opt/nomad-volumes/databases || echo $?

# Change permission
sudo chmod 775 /opt/nomad-volumes/grafana || echo $?
sudo chmod 775 /opt/nomad-volumes/databases || echo $?

#sudo chgrp 472:472 /opt/nomad-volumes/grafana || echo $?


