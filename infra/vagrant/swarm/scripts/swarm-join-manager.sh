#!/usr/bin/env bash

mng_token=$(</vagrant/mng_token) 

docker swarm join --token ${mng_token} 192.168.100.101
