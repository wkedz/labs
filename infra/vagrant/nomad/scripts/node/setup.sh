#!/bin/bash

echo "Node"

# Install dependencies.
apt-get update
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  jq \
  software-properties-common \
  hey \
  zip

# Download and install Docker.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
apt-get update
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io
docker run hello-world
usermod -aG docker vagrant

# Download hashicorp repository key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
add-apt-repository \
  "deb [arch=amd64] https://apt.releases.hashicorp.com \
  $(lsb_release -cs) \
  main"

# Install nomad
  apt-get update
  apt-get install -y \
    nomad

# Install consul

  apt-get update
  apt-get install -y \
    consul