# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.network "forwarded_port", guest: 7878, host: 7878 # Radarr
  config.vm.network "forwarded_port", guest: 8989, host: 8989 # Sonarr
  config.vm.network "forwarded_port", guest: 8686, host: 8686 # Lidarr
  config.vm.network "forwarded_port", guest: 8787, host: 8787 # Readarr
  config.vm.network "forwarded_port", guest: 9117, host: 9117 # Jackett
  config.vm.network "forwarded_port", guest: 9091, host: 9091 # Transmission

  # Workaround MacOS Monterey
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  end

  config.vm.provision "shell", path: "scripts/00-radarr.sh"
  config.vm.provision "shell", path: "scripts/01-sonarr.sh"
  config.vm.provision "shell", path: "scripts/02-lidarr.sh"
  config.vm.provision "shell", path: "scripts/03-readarr.sh"
  config.vm.provision "shell", path: "scripts/04-jackett.sh"
  config.vm.provision "shell", path: "scripts/05-transmission.sh"
end
