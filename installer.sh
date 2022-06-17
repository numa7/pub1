#!/bin/bash

set -e              #Exit script immediately on first error.

OS=`lsb_release -c` #check system for bullseye
MYSQLPSSWD=$2       #get var for mysql user pass
MYSQLUSR=$1         #get var for mysql username
echo "
-------------------
scr will install
MariDB with
user: $MYSQLUSR
passwd: $MYSQLPSSWD

-------------------"
sleep 1s

if echo "$OS" | grep -q 'bullseye' > /dev/null 2>&1 #if sys OK - lets install mariaDB
  then
     echo "
     -----------------
     your system is OK..
     $OS
     -----------------"
     sleep 1s
          
     #update sys
     echo "Update.. "
     sudo apt update -y && sudo apt upgrade -y
     
      #MySQL passw making
      if  [[ $MYSQLUSR != "" ]]
        then
        sudo apt -y install openssl
         if [[ $MYSQLPSSWD = "auto" ]]
           then 
             echo "            -------------------
             generate new psswd
            -------------------"
             MYSQLPSSWD=`openssl rand -base64 12`
             echo "            -------------------
             $MYSQLPSSWD
            -------------------"
             sleep 1s
           else 
             echo "             ----------------------------------------
             MariaDB will be installed with
             user: $MYSQLUSR
             pass: $MYSQLPSSWD
             ----------------------------------------"
             sleep 2s
         fi
        else
         echo "
         ----------------------------
         MariaDB will be installed
          with default user/pass
         ----------------------------" 
         sleep 1s
     fi   
     #install DB
     sudo apt install curl -y
     echo "     -------------------
     curl installed
     --------------------"
     sleep 1s
     curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash
     echo "     -------------------
     Maria downloaded
     --------------------"
     sleep 1s
     sudo apt-get install mariadb-server mariadb-client mariadb-backup -y
     echo "     -------------------
     Maria installed
     --------------------"
     sleep 2s
    
         if  [[ $MYSQLUSR = "" ]]  #check incoming vars         
           then
             echo "            with default params
            --------------------"
             sleep 2s
           else #adding user
             sudo mysql -u root -e "CREATE OR REPLACE USER '$MYSQLUSR'@'%' IDENTIFIED BY '$MYSQLPSSWD'"
             sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQLUSR'@localhost IDENTIFIED BY '$MYSQLPSSWD'"
             sudo mysql -u root -e "FLUSH PRIVILEGES"
             echo "             -------------------
             with
             user: $MYSQLUSR
             pass: $MYSQLPSSWD
             --------------------"
             sleep 2s
         fi  
     sudo service mysql restart
     sleep 2s     
  else       
    echo "    ---------------------
    system not supported...
    script for deb11 bullseye only
    -------------------------"
    sleep 3s
    exit
fi
USERS=$(sudo mysql -u root -e "SELECT User FROM mysql.user")
echo $USERS
####################

    echo "
    ---------------------
        Install php 
    ---------------------
    "
echo "Update.. "
sudo apt update -y && sudo apt upgrade -y
    sudo apt install wget -y
    sudo apt install apache2 -y
    sleep 1s
    sudo systemctl enable --now apache2
    sleep 1s
    sudo mkdir /var/www/html/phpmyadmin
    sudo apt install php php-json -y
    sudo systemctl enable --now mariadb
    sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
    sudo tar xvf phpMyAdmin-latest-all-languages.tar.gz
    sudo mv phpMyAdmin-*-all-languages/* /var/www/html/phpmyadmin
#    sudo chmod -R 0777 /etc/apache2/conf-available/phpmyadmin.conf
    sudo cp /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php
#    mycookissl=openssl rand -base64 32
#    sudo chmod -R 0777 /var/www/html/phpmyadmin/config.inc.php
#############################################################################    
#    sudo cat cat.config.inc.php > /var/www/html/phpmyadmin/config.inc.php
############################################################################    
    sudo chown -R www-data:www-data /var/www/html/phpmyadmin
    sleep 1s
    sudo touch /etc/apache2/conf-available/phpmyadmin.conf
    sudo chmod -R 0777 /etc/apache2/conf-available/phpmyadmin.conf
    sudo echo "
Alias /phpmyadmin /var/www/html/phpmyadmin

<Directory /var/www/html/phpmyadmin/>
   AddDefaultCharset UTF-8
   <IfModule mod_authz_core.c>
          <RequireAny>
      Require all granted
     </RequireAny>
   </IfModule>
</Directory>

<Directory /var/www/html/phpmyadmin/setup/>
   <IfModule mod_authz_core.c>
     <RequireAny>
       Require all granted
     </RequireAny>
   </IfModule>
</Directory>" > /etc/apache2/conf-available/phpmyadmin.conf

sleep 1s

        
    echo "
    ---------------------
       phpmyadmin OK
      restart apache2..
    ---------------------
    "
#    sudo cp /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
    sleep 1s
    sudo a2enconf phpmyadmin
    sleep 1s
    sudo systemctl restart apache2
    sleep 1s
    sudo systemctl reload apache2
    sleep 2s

    echo "
    ---------------------
    successfullyyy))
    ---------------------"

sleep 1s
exit
