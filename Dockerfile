FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
ENV DEBIAN_FRONTEND=noninteractive
RUN    apt-get install -y python3.7 python3.7-venv postgresql python3.7-dev libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev node-less git python3-pip

    #rm -rf /usr/bin/python3
    #ln -s /usr/bin/python3.9 /usr/bin/python3
    #apt-get install -y --reinstall python3-apt

RUN    mkdir -p /usr/share/cie
RUN    git clone https://gitlab.com/coopiteasy/scripts /usr/share/cie/scripts
RUN    ln -s /usr/share/cie/scripts/bin /usr/ciebin
#RUN    sed -i -e 's/nameserver 127.0.0.53/nameserver 9.9.9.9/g' /etc/resolv.conf
RUN useradd -m vagrant -s /bin/bash

USER vagrant
WORKDIR /home/vagrant
RUN git config --global pull.rebase false
RUN git config --global init.defaultBranch main
RUN git config --global user.email 'vagrant@vagrantbox'
RUN git config --global user.name 'vagrant'
RUN python3.7 -m pip install pipx
RUN ~/.local/bin/pipx ensurepath
ENV PATH="$PATH:/home/vagrant/.local/bin"
RUN pipx install pgcli
      #PIPX_HOME=/usr/local PIPX_BIN_DIR=/usr/local/bin sudo pipx install git+https://gitlab.com/coopiteasy/ociedoo#egg=ociedoo
RUN pipx install git+https://gitlab.com/coopiteasy/ociedoo#egg=ociedoo
      #PIPX_HOME=/usr/local PIPX_BIN_DIR=/usr/local/bin sudo pipx install git-aggregator
RUN pipx install git-aggregator
RUN mkdir -p /home/vagrant/cie/odoo12
#RUN ls -al
WORKDIR /home/vagrant/cie
RUN git clone https://gitlab.com/coopiteasy/cie-repositories
WORKDIR /home/vagrant/cie/odoo12
COPY aggregator.yaml /home/vagrant/cie/odoo12/repos.yml
#RUN mv /home/vagrant/aggregator.yaml repos.yml
RUN mkdir src
WORKDIR /home/vagrant/cie/odoo12/src
RUN gitaggregate -c ../repos.yml --jobs 2
WORKDIR /home/vagrant/cie/odoo12
RUN python3.7 -m venv .venv
#RUN /bin/bash -c "source .venv/bin/activate"
ENV PYTHON3=/home/vagrant/cie/odoo12/.venv/bin/python3
ENV PIP="$PYTHON3 -m pip"
RUN $PIP install --upgrade pip

# https://stackoverflow.com/questions/69100275/error-while-downloading-the-requirements-using-pip-install-setup-command-use-2
RUN $PIP install setuptools==58

RUN $PIP install -e src/odoo
RUN find . -name "requirements.txt" -print0 | xargs -0 -I{} $PIP install --force-reinstall -r {} || :
COPY odoo.conf .

# VERSION FIXES
# https://www.odoo.com/forum/help-1/odoo-11-no-module-named-web-web-kanban-error-125571
RUN $PIP uninstall -y jinja2
RUN $PIP install jinja2==2.11.2
      # https://stackoverflow.com/questions/72191560/importerror-cannot-import-name-soft-unicode-from-MarkupSafe
RUN $PIP uninstall -y MarkupSafe
RUN $PIP install MarkupSafe==2.0.1
      # https://stackoverflow.com/questions/61809465/modulenotfounderror-no-module-named-werkzeug-contrib-odoo-12
      # https://stackoverflow.com/questions/60976199/setting-up-an-odoo-12-developer-environment-issues-with-werkzeug-version
RUN $PIP uninstall -y Werkzeug
RUN $PIP install Werkzeug==0.16.01
      # https://www.odoo.com/forum/help-1/after-installing-pypdf2-i-have-another-problem-204763
RUN $PIP uninstall -y pypdf2 
RUN $PIP install PyPDF2==1.26.0

USER root
RUN apt-get install sudo
RUN (echo vagrant; echo vagrant) | passwd vagrant
RUN usermod -a -G sudo vagrant
RUN sed -i -e "s/external_pid_file = '\/var\/run\/postgresql\/14-main.pid'/external_pid_file = \'\/var\/run\/postgresql\/.s.PGSQL.5432\'/g" /etc/postgresql/14/main/postgresql.conf
RUN su - postgres -c "/usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/14/main/postgresql.conf" & sleep 1; su - postgres -c "createuser -s vagrant"
RUN rm -rf /var/run/postgresql/.s.PGSQL.5432
#RUN psql -l
USER vagrant
COPY entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
