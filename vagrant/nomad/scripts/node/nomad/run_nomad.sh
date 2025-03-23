#!/bin/bash

sudo nomad agent -config /etc/nomad.d/nomad.hcl -log-level=debug &

sleep 10
