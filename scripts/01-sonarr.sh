#!/usr/bin/env bash

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 2009837CBFFD68F45BC180471F4F90DE2A9B4BF8
echo "deb https://apt.sonarr.tv/ubuntu focal main" | tee /etc/apt/sources.list.d/sonarr.list
apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install sonarr -y

mkdir -p /home/sonarr
chown -R sonarr:sonarr /home/sonarr
