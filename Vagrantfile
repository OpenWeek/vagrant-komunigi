# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/ubuntu2204"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 8012, host: 8012

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provision "file", source: "aggregator.yaml", destination: "~/"
  config.vm.provision "file", source: "odoo.conf", destination: "~/"

  config.vm.provider "libvirtd" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
    vb.memory = "2048"
  end

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
    vb.memory = "2048"
  end

  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    #set -xe
    add-apt-repository ppa:deadsnakes/ppa
    apt-get update
    apt-get install -y python3.7 python3.7-venv postgresql python3.7-dev libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev node-less git python3-pip
    export USER=vagrant

    #rm -rf /usr/bin/python3
    #ln -s /usr/bin/python3.9 /usr/bin/python3
    #apt-get install -y --reinstall python3-apt

    mkdir -p /usr/share/cie
    git clone https://gitlab.com/coopiteasy/scripts /usr/share/cie/scripts
    ln -s /usr/share/cie/scripts/bin /usr/ciebin
    sed -i -e 's/nameserver 127.0.0.53/nameserver 9.9.9.9/g' /etc/resolv.conf

    su - "$USER" -c "
      git config --global pull.rebase false
      git config --global init.defaultBranch main
      git config --global user.email 'vagrant@vagrantbox'
      git config --global user.name 'vagrant'
      python3.7 -m pip install pipx
      ~/.local/bin/pipx ensurepath
      export PATH="$PATH:/home/vagrant/.local/bin"
      pipx install pgcli
      #PIPX_HOME=/usr/local PIPX_BIN_DIR=/usr/local/bin sudo pipx install git+https://gitlab.com/coopiteasy/ociedoo#egg=ociedoo
      pipx install git+https://gitlab.com/coopiteasy/ociedoo#egg=ociedoo
      #PIPX_HOME=/usr/local PIPX_BIN_DIR=/usr/local/bin sudo pipx install git-aggregator
      pipx install git-aggregator
      mkdir -p ~/cie/odoo12
      sudo -u postgres createuser -s "${USER}"
      psql -l
      cd ~/cie
      git clone https://gitlab.com/coopiteasy/cie-repositories
      cd ~/cie/odoo12
      mv ~/aggregator.yaml repos.yml
      mkdir src
      cd src
      gitaggregate -c ../repos.yml --jobs 2
      cd ..
      python3.7 -m venv .venv
      source .venv/bin/activate
      ~/cie/odoo12/.venv/bin/python3 -m pip install --upgrade pip
      pip install -e src/odoo
      find . -name "requirements.txt" -print0 | xargs -0 -I{} pip3 install --force-reinstall -r {}
      mv ~/odoo.conf .

      # VERSION FIXES
      # https://stackoverflow.com/questions/69100275/error-while-downloading-the-requirements-using-pip-install-setup-command-use-2
      pip install setuptools==58
      # https://www.odoo.com/forum/help-1/odoo-11-no-module-named-web-web-kanban-error-125571
      pip uninstall -y jinja2
      pip install jinja2==2.11.2
      # https://stackoverflow.com/questions/72191560/importerror-cannot-import-name-soft-unicode-from-markupsafe
      pip uninstall -y MarkupSafe
      pip install MarkupSafe==2.0.1
      # https://stackoverflow.com/questions/61809465/modulenotfounderror-no-module-named-werkzeug-contrib-odoo-12
      # https://stackoverflow.com/questions/60976199/setting-up-an-odoo-12-developer-environment-issues-with-werkzeug-version
      pip3 uninstall -y Werkzeug
      pip3 install Werkzeug==0.16.01
      # https://www.odoo.com/forum/help-1/after-installing-pypdf2-i-have-another-problem-204763
      pip3 uninstall -y pypdf2 
      pip3 install PyPDF2==1.26.0
    "
  SHELL
end
