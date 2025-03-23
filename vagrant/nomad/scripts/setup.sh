#!/bin/bash

echo "Common setup."

HOST=$1
IP=$2

# # Update packages
# sudo apt-get update

# # Install required packages
# sudo apt-get install -y software-properties-common curl jq wget git vim

# Generate key
ssh-keygen -t rsa -C vagrant@$(hostname) -f /home/vagrant/.ssh/vagrant_$(hostname)_id_key -N ""

# Change user:group of created key, because under provision we are root
sudo chown vagrant:vagrant /home/vagrant/.ssh/vagrant_$(hostname)_id_key /home/vagrant/.ssh/vagrant_$(hostname)_id_key.pub

# Use them as main keys
ln -s /home/vagrant/.ssh/vagrant_$(hostname)_id_key /home/vagrant/.ssh/id_rsa
ln -s /home/vagrant/.ssh/vagrant_$(hostname)_id_key.pub /home/vagrant/.ssh/id_rsa.pub

cp /home/vagrant/.ssh/vagrant_$(hostname)_id_key /vagrant/tmp/ssh

# Add public key to authorization keys
cat /home/vagrant/.ssh/vagrant_${HOST}_id_key.pub >> /vagrant/tmp/ssh/authorized_keys 
chown vagrant:vagrant /vagrant/tmp/ssh/authorized_keys 

cat /vagrant/tmp/ssh/vagrant_manager_id_key.pub >> /home/vagrant/.ssh/authorized_keys

# There is a problem with authorization after reboot. It have to do with 
# permission 
# https://help.ubuntu.com/community/SSH/OpenSSH/Keys

# Add existing key
# cat /home/vagrant/.ssh/authorized_keys >> /vagrant/tmp/ssh/authorized_keys 

# # And remove it 
# rm /home/vagrant/.ssh/authorized_keys

# # # Link authorized keys to all
# ln -s /vagrant/tmp/ssh/authorized_keys /home/vagrant/.ssh/authorized_keys
# chown -h vagrant:vagrant /home/vagrant/.ssh/authorized_keys
# chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

# Add info about this host to config for ssh 
pattern="
    Host ${HOST}\n
        HostName ${IP}\n
        StrictHostKeyChecking no\n

"
echo -e ${pattern} >> /vagrant/tmp/ssh/config

ln -s /vagrant/tmp/ssh/config /home/vagrant/.ssh/config

# Add host info to ansible hosts
echo "${HOST} ansible_host=${IP} ansible_user=vagrant ansible_become=true" >> /vagrant/tmp/ansible/ansible_hosts
