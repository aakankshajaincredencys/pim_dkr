FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get clean all
RUN apt-get -y update && \
 apt-get install -y tzdata && \
 ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && dpkg-reconfigure -f noninteractive tzdata
RUN apt-get install -yq --no-install-recommends apt-utils \
    curl apache2 \
    libapache2-mod-php7.2 \
	php7.2 \
    php7.2-cli \
    php7.2-json \
    php7.2-curl \
    php7.2-fpm \
	php7.2-common \
    php7.2-gd \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-mysql \
	php7.2-opcache \
    php7.2-soap \
    php7.2-sqlite3 \
    php7.2-xml \
    php7.2-zip \
	php7.2-xsl \
	php7.2-bcmath \
	php7.2-iconv \
    php7.2-intl \
    php-imagick \
    openssl \
    mysql-client

# Enable apache mods.
RUN a2enmod rewrite expires headers php7.2

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Update the default apache site with the custom config
ADD apache_config.conf /etc/apache2/sites-enabled/000-default.conf

# Configure apache
RUN echo '. /etc/apache2/envvars' >> /root/run_apache.sh && \
 echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh && \
 echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh && \
 echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh && \
 chmod 755 /root/run_apache.sh

CMD /root/run_apache.sh

# volumes
VOLUME /var/www/html
WORKDIR /var/www/html

# Get Pimcore content
RUN chown -R www-data:www-data /var/www/html

# Set the port
EXPOSE 80

# Update the default run.sh
ADD run.sh /root/run.sh

# Execut the run.sh 
CMD /root/run.sh