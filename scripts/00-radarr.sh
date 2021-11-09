#!/bin/bash
#### Description: Radarr 3.2+ (.NET) Debian install
#### Originally written by: DoctorArr - doctorarr@the-rowlands.co.uk on 2021-10-01 v1.0
#### Version v1.1 2021-10-02 - Bakerboy448 (Made more generic and conformant)
#### Version v1.1.1 2021-10-02 - DoctorArr (Spellcheck and boilerplate update)
#### Version v2.0.0 2021-10-09 - Bakerboy448 (Refactored and ensured script is generic. Added more variables.)
#### Updates by: The Radarr Community
#### Thanks to Bakerboy448 for the guidance and improved wiki entry & script
#### Original author note: For the avoidance of doubt, this script is just to help the next person along and improve the Radarr install experience.
#### Its target is the beginner/novice with 'I know enough to be dangerous' experience.
#### If you see any errors or improvements please update the script for future users.

## Am I root?, need root!

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit
fi

## Const
#### Update these variables as required for your specific instance

app="radarr"                        # App Name
app_uid="radarr"                    # {Update me if needed} User App will run as and the owner of it's binaries
app_guid="media"                    # {Update me if needed} Group App will run as.
app_port="7878"                     # Default App Port; Modify config.xml after install if needed
app_prereq="curl mediainfo sqlite3" # Required packages
app_umask="0002"                    # UMask the Service will run as
app_bin=${app^}                     # Binary Name of the app
bindir="/opt/${app^}"               # Install Location
branch="master"                     # {Update me if needed} branch to instal
datadir="/var/lib/radarr/"          # {Update me if needed} AppData directory to use

## Create App user if it doesn't exist

PASSCHK=$(grep -c "$app_uid:" /etc/passwd)
if [ "$PASSCHK" -ge 1 ]; then
    groupadd -f $app_guid
    usermod -a -G $app_uid $app_guid
    echo "User: [$app_uid] seems to exist. Skipping creation, but adding to the group if needed. Ensure the User [$app_uid] and Group [$app_guid] are setup properly.  Specifically the application will need access to your download client and media files."
else
    echo "User: [$app_uid] created with disabled password."
    adduser --disabled-password --gecos "" $app_uid
    groupadd -f $app_guid
    usermod -a -G $app_uid $app_guid
fi
## Stop the App if running

if service --status-all | grep -Fq "$app"; then
    systemctl stop $app
    sytemctl disable $app.service
fi

## Create Appdata Directory

## AppData
mkdir -p $datadir
chown -R $app_uid:$app_uid $datadir
chmod 775 $datadir

## Download and install the App

## prerequisite packages
apt install $app_prereq

ARCH=$(dpkg --print-architecture)
## get arch
dlbase="https://$app.servarr.com/v1/update/$branch/updatefile?os=linux&runtime=netcore"
case "$ARCH" in
"amd64") DLURL="${dlbase}&arch=x64" ;;
"armhf") DLURL="${dlbase}&arch=arm" ;;
"arm64") DLURL="${dlbase}&arch=arm64" ;;
*)
    echo_error "Arch not supported"
    exit 1
    ;;
esac
echo "Downloading..."
wget --content-disposition "$DLURL"
tar -xvzf ${app^}.*.tar.gz
echo "Installation files downloaded and extracted"

## remove existing installs
echo "Removing existing installation"
rm -rf $bindir
echo "Installing..."
mv "${app^}" /opt/
chown $app_uid:$app_uid -R $bindir
rm -rf "${app^}.*.tar.gz"
echo "App Installed"
##Configure Autostart

#Remove any previous app .service
echo "Removing old service file"
rm -rf /etc/systemd/system/$app.service

##Create app .service with correct user startup
echo "Creating service file"
cat << EOF | tee /etc/systemd/system/$app.service >/dev/null
[Unit]
Description=${app^} Daemon
After=syslog.target network.target
[Service]
User=$app_uid
Group=$app_guid
UMask=$app_umask
Type=simple
ExecStart=$bindir/$app_bin -nobrowser -data=$datadir
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

##Start the App
echo "Service file created. Attempting to start the app"
systemctl -q daemon-reload
systemctl enable --now -q "$app"

## Finish update
host=$(hostname -I)
ip_local=$(grep -oP '^\S*' <<<"$host")
echo ""
echo "Install complete"
echo "Browse to http://$ip_local:$app_port for the ${app^} GUI"
