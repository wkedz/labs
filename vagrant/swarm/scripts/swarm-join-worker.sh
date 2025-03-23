#!/usr/bin/env bash

wrk_token=$(</vagrant/wrk_token) 

docker swarm join --token ${wrk_token} 192.168.100.101
