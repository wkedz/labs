#!/usr/bin/env bash

docker swarm init --advertise-addr 192.168.100.101

docker swarm join-token -q worker > /vagrant/wrk_token
docker swarm join-token -q manager > /vagrant/mng_token
