#!/bin/bash

consul agent -config-dir /etc/consul.d/consul.hcl -log-level=info &

