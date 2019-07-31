#!/bin/bash
#source settings.cfg

rootdbpass="mypassword123"
# WEB host from web connect to db
host_web=192.168.200.12 
hostdb=192.168.200.11
portdb=3306
dbname="moodle"
moodleuser="webmoodle"
moodlepassword="yourpassword123"

echo "Disable selinux"
sudo setenforce Permissive

echo "Configuring Apache, add VHost"

sudo cat <<EOF > /etc/httpd/conf.d/moodle.conf
<VirtualHost *:80>
    ServerAdmin admin@moodle.local
    DocumentRoot /var/www/html/moodle
    ServerName moodle.local
    ServerAlias www.moodle.local
    #ServerAlias 192.168.200.12
    Alias /moodle “/var/www/html/moodle/”
    <Directory /var/www/html/moodle>
        Options SymLinksIfOwnerMatch
       AllowOverride All
    </Directory>

    ErrorLog /var/log/httpd/moodle-error_log
    CustomLog /var/log/httpd/moodle-access_log common
</VirtualHost>
EOF

echo "Virtuall host has been added"

echo "Creating Moodle directories..."

sudo mkdir -p /var/moodle/data
sudo chmod 0777 /var/moodle/data
sudo chown -R apache:apache /var/moodle/data

cd /var/www/html

echo "Downloading Moodle" 
#sudo git clone https://github.com/moodle/moodle.git .
sudo git clone -b MOODLE_36_STABLE git://git.moodle.org/moodle.git 

echo "Installing Moodle cli mode"

#sudo chown -R apache:apache /var/www/html/moodle
# --wwwroot="http://moodle.local/"\

sudo /usr/bin/php  moodle/admin/cli/install.php --lang="en"\
	--wwwroot="http://moodle.local"\
	--dataroot="/var/moodle/data"\
	--dbtype="mariadb"\
        --dbhost="$hostdb"\
	--dbname="moodle"\
	--dbuser="$moodleuser"\
        --dbpass="$moodlepassword"\
        --dbport="$portdb"\
	--fullname="Moodle"\
	--shortname="moodle"\
        --adminuser="admin"\
	--adminpass="myadminpassword1"\
	--agree-license\
	--non-interactive

sudo chmod 755 -R /var/www/html/moodle

echo "Add alias : localhost moodle.local - to /etc/hosts"
sudo echo "localhost moodle.local" >> /etc/hosts
echo "add $host_web to etc/hosts"
sudo echo "$host_web moodle.local">> /etc/hosts

echo "Restarting network and Apache..."
sudo systemctl restart network.service
sudo systemctl restart httpd.service

sudo cat <<EOF
Service installed at $host_web
You will need to add a hosts file entry for:
moodle.local points to $host_web
username: admin
password: myadminpassword1
EOF
sudo cat <<EOF > /etc/cron.d/moodle
* * * * * /usr/bin/php /var/www/moodle/html/moodle/admin/cli/cron.php
EOF