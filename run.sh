#!/bin/bash

# temp. start mysql to do all the install stuff
/usr/bin/mysqld_safe > /dev/null 2>&1 &

# ensure mysql is running properly
sleep 20 


# install composer if needed
if [ ! -x /usr/local/bin/composer ]; then

    echo "Installing Composer ... "

    cd /tmp

    EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
    /usr/bin/php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE=$(/usr/bin/php -r "echo hash_file('SHA384', 'composer-setup.php');")

    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
    then
        >&2 echo 'ERROR: Invalid installer signature'
        rm composer-setup.php
        exit 1
    fi

    /usr/bin/php composer-setup.php --quiet
    mv composer.phar /usr/local/bin/composer
    rm composer-setup.php
fi

# install pimcore if needed
if [ ! -d /var/www/pimcore ]; then

  echo "Installing Pimcore ... "

  # download & extract
  cd /var/www
  rm -r /var/www/*
  echo "Downloading Pimcore 5 ... "
  sudo -u www-data wget https://www.pimcore.org/download-5/pimcore-unstable.zip -O /tmp/pimcore.zip 2>/dev/null >/dev/null
  echo "Unpacking Pimcore 5 ..."
  sudo -u www-data unzip /tmp/pimcore.zip -d /var/www/ 2>/dev/null >/dev/null
  rm /tmp/pimcore.zip 

  mysql -u root -e "CREATE DATABASE project_database charset=utf8mb4;"
  mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'project_user'@'%' IDENTIFIED BY 'secretpassword' WITH GRANT OPTION;"

  # ??
  # sudo -u www-data /var/www/bin/console cache:clear
  # sudo -u www-data -- composer install

fi

# stop temp. mysql service
mysqladmin -uroot shutdown

echo "Finalizing startup."

exec supervisord -n
