servers=[
  
  {
    :hostname => "db",
    :ip => "192.168.200.11",
    :box => "centos/7",
    :ram => 1024,
    :cpu => 1
  },
{
    :hostname => "web",
    :ip => "192.168.200.12",
    :box => "centos/7",
    :ram => 2048,
    :cpu => 1

  }

]


Vagrant.configure(2) do |config|
    servers.each do |machine|
        config.vm.define machine[:hostname] do |node|
            node.vm.box = machine[:box]
            node.vm.hostname = machine[:hostname]
            node.vm.network "private_network", ip: machine[:ip], virtualbox__intnet: "intnet"
            node.vm.provider "virtualbox" do |vb|
                vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
                vb.customize ["modifyvm", :id, "--cpus", machine[:cpu]]   
            end
        end
    end
end


Vagrant.configure("2") do |config|
  #config.vm.provision "shell", inline: "echo Hello"
   
   config.vm.define "db" do |db|
    db.vm.provision "shell", inline: <<-SHELL
        sudo yum update -y   
        sudo yum -y install mc
        sudo yum -y install mariadb-server 
        sudo systemctl start mariadb.service
        sudo systemctl enable mariadb.service
    SHELL
    db.vm.provision "shell", path: "mysql_sec.sh"
     
  end

  config.vm.define "web" do |web|
    web.vm.network "forwarded_port", guest: 80, host: 8080
    web.vm.provision "shell", inline: <<-SHELL
        sudo yum update -y
        sudo yum -y install mc
        sudo yum install -y httpd
        sudo yum install -y git 
        sudo echo "starting httpd"
        sudo systemctl start httpd.service
        # To make sure if Apache server is running
        sudo systemctl status httpd 
        sudo systemctl enable httpd.service  # to do is enable Apache to start on boot     
        
        # To install PHP 7.3 and its libraries:
        sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm 
        sudo yum -y install epel-release yum-utils
        sudo yum-config-manager --disable remi-php54  
        sudo yum-config-manager --enable remi-php73
        #sudo yum -y install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-intl
        sudo yum -y install php php-common php-intl php-zip php-soap php-xmlrpc php-opcache php-mbstring php-gd php-curl php-mysql php-xml 
        sudo systemctl restart httpd
    SHELL
       web.vm.provision "shell", path: "scenario.sh"
  end
end



