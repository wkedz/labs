#!/bin/bash

echo "Host script"

if [ -a ./tmp/ssh/vagrant_manager_id_key.pub ] ; then
    echo "Setup already done, nothing to do."
else
    echo "Setup..."

    mkdir -p ./tmp/ansible
    mkdir -p ./tmp/ssh

    # Make buffor files for symboli links
    touch ./tmp/ansible/anansible_hosts
    touch ./tmp/ssh/authorized_keys
    touch ./tmp/ssh/config

    chmod 600 ./tmp/ssh/authorized_keys
    chmod 700 ./tmp/ssh

    # Generate key
    ssh-keygen -t rsa -C vagrant@manager -f ./tmp/ssh/vagrant_manager_id_key -N ""

    # Change user of tmp
    chown -R 1000:1000 ./tmp/*
    chown 1000:1000 ./tmp
fi
