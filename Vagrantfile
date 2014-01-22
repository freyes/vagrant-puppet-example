# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  facter = {"db_ip" => "10.0.3.10",
            "web_ip" => "10.0.3.11"}

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "256"]
  end

  config.vm.provision :puppet,
                      :options => ["--verbose --debug"] do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file  = "init.pp"
    puppet.module_path  = "puppet/modules"
    puppet.facter = facter
  end

  # per node config
  config.vm.define "db" do |db|
    db.vm.hostname = "db01"
    # db.vm.network :private_network, ip: facter["db_ip"]
  end

  config.vm.define "web" do |web|
    web.vm.hostname = "web01"
    # web.vm.network :private_network, ip: facter["web_ip"]
    web.vm.network "forwarded_port", guest: 80, host: 5000
  end
end
