FROM centos:7
MAINTAINER wwtg99 <wwtg99@126.com>

# Install base library
RUN set -x && \
    yum install -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    wget \
    make \
    cmake

# Update yum repo
# RUN wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

# Install library
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install epel-release && \
    rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm && \
    yum install -y zlib \
    zlib-devel \
    openssl \
    openssl-devel \
    pcre-devel \
    libxml2 \
    libxml2-devel \
    libcurl \
    libcurl-devel \
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libmcrypt-devel \
    openssh-server \
    postgresql-devel \
    python-setuptools

# Add dir & user
RUN mkdir -p /data/{www,phpext,conf,log} && \
    useradd -r -s /sbin/nologin -d /data/www -m -k no www && \
    chown -R www:www /data/www && \
    chown -R www:www /data/log

# Install PHP
RUN yum install -y php71w php71w-fpm php71w-cli php71w-common php71w-devel \
    php71w-gd php71w-pdo php71w-mysql php71w-mbstring php71w-bcmath \
    php71w-fpm php71w-opcache php71w-pgsql php71w-process php71w-xml

# Install PHP mongo
RUN wget https://pecl.php.net/get/mongodb-1.4.0.tgz -O /data/phpext/mongodb-1.4.0.tgz && \
    tar zxf /data/phpext/mongodb-1.4.0.tgz -C /data/phpext
WORKDIR /data/phpext/mongodb-1.4.0
RUN /usr/bin/phpize && \
    ./configure --with-php-config=/usr/bin/php-config && \
    make && make install && \
    echo "extension=mongodb.so" > /etc/php.d/mongodb.ini

# Install nginx
RUN yum install -y nginx

# Install supervisor
RUN easy_install supervisor && \
    mkdir -p /var/{log/supervisor,run/{sshd,supervisord}}

# Install composer
RUN wget https://getcomposer.org/installer -O /data/phpext/composer-setup.php
WORKDIR /data/phpext
RUN php composer-setup.php && ln -s /data/phpext/composer.phar /bin/composer

# Clean OS
RUN yum remove -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \
    yum clean all && \
    rm -rf /tmp/* /var/cache/{yum,ldconfig} /etc/my.cnf{,.d} && \
    mkdir -p --mode=0755 /var/cache/{yum,ldconfig} && \
    find /var/log -type f -delete

# Add conf
RUN mkdir -p /data/conf/{nginx,supervisord}
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/php-fpm.conf /etc/php-fpm.d/www.conf
ADD conf/supervisord.conf /etc/supervisord.conf

# Create volume
VOLUME ["/data/www", "/data/conf/nginx", "/data/conf/supervisord", "/data/log"]

WORKDIR /data/www
ADD index.php /data/www/

# Start script
ADD script.sh /
ADD start.sh /
RUN chmod +x /start.sh
RUN /bin/bash /script.sh

# Set port
EXPOSE 80 443

# Start it
# ENTRYPOINT ["/start.sh"]

# Start web server
CMD ["/bin/bash", "/start.sh"]
