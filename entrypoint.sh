#! /bin/bash -xe
echo vagrant | sudo -S su - postgres -c "/usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/14/main/postgresql.conf" &
sleep 5
cd /home/vagrant/cie/odoo12
source .venv/bin/activate
odoo -c odoo.conf
