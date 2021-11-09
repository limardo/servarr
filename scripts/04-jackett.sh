#!/usr/bin/env bash

apt-get install -y jq

JACKETT_TARBALL=$(curl --silent "https://api.github.com/repos/Jackett/Jackett/releases/latest" | jq -r '.assets[] | select(.name == "Jackett.Binaries.LinuxAMDx64.tar.gz").browser_download_url')

echo "Downloading..."
mkdir -p /opt/jackett
wget --content-disposition "$JACKETT_TARBALL" -O /tmp/jackett.tar.gz
tar -xf /tmp/jackett.tar.gz -C /opt/jackett --strip-components=1
chmod -R 777 /opt/jackett
sh /opt/jackett/install_service_systemd.sh
