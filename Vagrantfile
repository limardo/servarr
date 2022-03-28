# -*- mode: ruby -*-
# vi: set ft=ruby :

project_path = "/home/vagrant/servarr"

inital_script = <<-SCRIPT
sudo chown -R vagrant:vagrant #{project_path}

cat <<EOF > #{project_path}/.env
SERVARR_PUID=1000
SERVARR_PGID=1000
RADARR_CONFIG_PATH=#{project_path}/data/config/radarr
RADARR_MOVIES_PATH=#{project_path}/data/movies
RADARR_DOWNLOAD_PATH=#{project_path}/data/download
SONARR_CONFIG_PATH=#{project_path}/data/config/sonarr
SONARR_TV_PATH=#{project_path}/data/tv
SONARR_DOWNLOAD_PATH=#{project_path}/data/download
LIDARR_CONFIG_PATH=#{project_path}/data/config/lidarr
LIDARR_MUSIC_PATH=#{project_path}/data/music
LIDARR_DOWNLOAD_PATH=#{project_path}/data/download
READARR_CONFIG_PATH=#{project_path}/data/config/readarr
READARR_BOOK_PATH=#{project_path}/data/books
READARR_DOWNLOAD_PATH=#{project_path}/data/download
PROWLARR_CONFIG_PATH=#{project_path}/data/config/prowlarr
EOF
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian10"

  config.vm.define 'Vagrant' do |machine|
    machine.vm.network "forwarded_port", guest: 7878, host: 7878 # Radarr
    machine.vm.network "forwarded_port", guest: 8989, host: 8989 # Sonarr
    machine.vm.network "forwarded_port", guest: 8686, host: 8686 # Lidarr
    machine.vm.network "forwarded_port", guest: 8787, host: 8787 # Readarr
    machine.vm.network "forwarded_port", guest: 9696, host: 9696 # Prowlarr
    machine.vm.network "forwarded_port", guest: 8191, host: 8191 # Flaresolverr

    machine.vm.provider 'virtualbox' do |v|
        v.name = 'serverr-webserver-1'
        # Workaround MacOS Monterey
        v.gui = true
    end

    machine.vm.synced_folder "data/", "#{project_path}/data"

    machine.trigger.before :provisioner_run, type: :hook  do |trigger|
        trigger.name = "Servarr directory"
        trigger.info = "Fixing permissions user and group and adding env file"
        trigger.run_remote = {inline: inital_script}
    end
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.groups = {
        'webserver' => ['Vagrant'],
        'webserver:vars' => {
            'ansible_python_interpreter' => '/usr/bin/python3',
            'servarr_path' => project_path,
        }
    }
  end
end
