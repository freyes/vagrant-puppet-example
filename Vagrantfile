# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file  = "init.pp"
    puppet.module_path  = "puppet/modules"
  end

  # per node config
  config.vm.define "web" do |web|
    web.vm.hostname = "web01"
    web.vm.network "forwarded_port", guest: 80, host: 2200
  end

  config.vm.define "db" do |db|
    db.vm.hostname = "db01"
  end
end
