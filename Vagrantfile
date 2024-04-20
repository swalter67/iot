# -*- mode: ruby -*-
# vi: set ft=ruby :

NODES = [
  { :hostname => 'swalterS', :ip => '192.168.42.110', :role => 'master', :box => 'ubuntu/focal64' },
  { :hostname => 'swalterSW',  :ip => '192.168.42.111', :role => 'agent', :box => 'ubuntu/focal64' }
]

Vagrant.configure("2") do |config|
  # Configuration de base pour tous les nœuds
  NODES.each do |node|
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      node_config.vm.hostname = node[:hostname]
      node_config.vm.network "private_network", ip: node[:ip]

      # Dossier partagé pour le token
      node_config.vm.synced_folder "./shared", "/home/vagrant/shared"

      # Scripts de provisionnement
      if node[:role] == 'master'
        node_config.vm.provision "shell", path: "install_k3s_master.sh"
      elsif node[:role] == 'agent'
        node_config.vm.provision "shell", inline: <<-SHELL
          echo "Waiting for master to complete setup..."
          while [ ! -f /home/vagrant/shared/token ]; do sleep 5; done
          bash /home/vagrant/shared/worker_node_setup.sh $(cat /home/vagrant/shared/token)
        SHELL
      end
    end
  end
end
