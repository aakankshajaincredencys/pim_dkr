#!/bin/bash


# install composer
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

# Pimcore Commands
if [ ! -d /var/www/html ]; then

	git clone https://github.com/pimcore/skeleton.git
	mkdir -p /var/www/html
	mv skeleton/* /var/www/html
	rm -rf skeleton
	cd /var/www/html
	chown -R www-data:www-data /var/www/html
	sudo -u www-data -- composer update
	sudo -u www-data /var/www/html/bin/console deployment:classes-rebuild
	sudo -u www-data /var/www/html/bin/console cache:clear
	sudo -u www-data /var/www/html/bin/console pimcore:cache:clear

fi

cd /var/www/html
sudo -u www-data -- composer update
sudo -u www-data /var/www/html/bin/console deployment:classes-rebuild
sudo -u www-data /var/www/html/bin/console cache:clear
sudo -u www-data /var/www/html/bin/console pimcore:cache:clear
