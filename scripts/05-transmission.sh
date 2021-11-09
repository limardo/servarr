#!/usr/bin/env bash

add-apt-repository ppa:transmissionbt/ppa
apt-get update
apt-get install transmission-cli transmission-common transmission-daemon -y
