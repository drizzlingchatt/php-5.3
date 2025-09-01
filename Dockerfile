# Dockerfile for PHP 5.3
# Uses Ubuntu 14.04 as base (old, but compatible)
FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive

# Add legacy Ubuntu 14.04 sources and install dependencies
RUN sed -i 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget build-essential libxml2-dev libssl-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libmcrypt-dev libreadline-dev libicu-dev libxslt1-dev libfreetype6-dev libxpm-dev pkg-config vim libmysqlclient-dev && \
    apt-get clean

# Debug: List MySQL client libraries and headers (will not fail build)
RUN echo "Listing /usr/lib for libmysqlclient* for debug:" && ls -l /usr/lib/ | grep mysqlclient || true && \
    echo "Listing /usr/include/mysql for headers for debug:" && ls -l /usr/include/mysql || true

# Preload MySQL 5.5 client dev tarball
COPY build-helpers/mysql-5.5.62-linux-glibc2.12-x86_64.tar.gz /tmp/
# Fallback: Extract MySQL 5.5 client dev files if missing
RUN if [ ! -f /usr/lib/libmysqlclient.so ] || [ ! -f /usr/include/mysql/mysql.h ]; then \
      echo "MySQL client files missing, extracting MySQL 5.5 client dev tarball..."; \
      cd /tmp && \
      tar -xzf mysql-5.5.62-linux-glibc2.12-x86_64.tar.gz && \
      cp -r mysql-5.5.62-linux-glibc2.12-x86_64/include/* /usr/include/mysql/ && \
      cp -r mysql-5.5.62-linux-glibc2.12-x86_64/lib/libmysqlclient.so* /usr/lib/; \
    fi

# Install Apache and required modules
RUN apt-get update && \
    apt-get install -y apache2 apache2-dev && \
    apt-get clean
RUN ln -sf $(find /usr/lib -name 'libXpm.so*' | head -n 1) /usr/lib/libXpm.so
RUN cp /etc/mime.types /etc/apache2/mime.types
RUN mkdir -p /usr/include/freetype2/config && \
    mkdir -p /usr/include/freetype2/freetype/ && \
    for header in freetype.h ftsystem.h ftimage.h fttypes.h ftmodapi.h ft2build.h; do \
      if [ -f /build-helpers/$header ]; then \
        cp /build-helpers/$header /usr/include/freetype2/$header; \
      else \
        wget -O /usr/include/freetype2/$header https://raw.githubusercontent.com/freetype/freetype/master/include/freetype/$header || wget -O /usr/include/freetype2/$header https://raw.githubusercontent.com/freetype/freetype/master/include/$header; \
      fi; \
    done && \
    for header in ftheader.h ftconfig.h; do \
      if [ -f /build-helpers/$header ]; then \
        cp /build-helpers/$header /usr/include/freetype2/config/$header; \
      else \
        wget -O /usr/include/freetype2/config/$header https://raw.githubusercontent.com/freetype/freetype/master/include/freetype/config/$header; \
      fi; \
    done && \
    for f in /usr/include/freetype2/*.h; do ln -sf $f /usr/include/; done && \
    for f in /usr/include/freetype2/config/*.h; do ln -sf $f /usr/include/; done && \
    chmod 644 /usr/include/freetype2/*.h /usr/include/freetype2/config/*.h /usr/include/*.h || true && \
    chown root:root /usr/include/freetype2/*.h /usr/include/freetype2/config/*.h /usr/include/*.h || true && \
    mkdir -p /usr/include/freetype && \
    cp /usr/include/freetype2/*.h /usr/include/freetype/ && \
    cp /usr/include/freetype2/config/*.h /usr/include/freetype/ && \
    cp /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h


# Download PHP 5.3 source
WORKDIR /usr/src
RUN wget https://museum.php.net/php5/php-5.3.29.tar.gz && \
    tar -xzf php-5.3.29.tar.gz

# Copy MySQL client libraries and headers directly to /usr/lib and /usr/include/mysql for PHP 5.3 configure compatibility
RUN mkdir -p /usr/include/mysql && \
    cp -a /usr/include/mysql/* /usr/include/mysql/ || true && \
    cp -a /usr/lib/x86_64-linux-gnu/libmysqlclient.so* /usr/lib/ 2>/dev/null || true && \
    cp -a /usr/lib/libmysqlclient.so* /usr/lib/ 2>/dev/null || true

WORKDIR /usr/src/php-5.3.29
# Fix linker error for ARM by setting LDFLAGS
ENV LDFLAGS="-lstdc++ -L/usr/lib/x86_64-linux-gnu -L/usr/lib"
# Help PHP build find freetype.h and mysql headers
ENV CPPFLAGS="-I/usr/include -I/usr/include/freetype2 -I/usr/include/mysqlclient -I/usr/include/mysql"
COPY build-helpers/config.guess /usr/src/php-5.3.29/config.guess
COPY build-helpers/config.sub /usr/src/php-5.3.29/config.sub
RUN if [ ! -f /usr/src/php-5.3.29/config.guess ]; then \
    wget -O /usr/src/php-5.3.29/config.guess "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"; \
  fi && \
  if [ ! -f /usr/src/php-5.3.29/config.sub ]; then \
    wget -O /usr/src/php-5.3.29/config.sub "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"; \
  fi

RUN echo "Listing /usr/include for freetype headers:" && ls -l /usr/include | grep freetype && \
    echo "Listing /usr/include/freetype2 for headers:" && ls -l /usr/include/freetype2

RUN ./configure \
    --prefix=/usr/local/php5.3 \
    --with-config-file-path=/usr/local/php5.3/etc \
    --with-config-file-scan-dir=/usr/local/php5.3/etc/conf.d \
    --enable-mbstring \
    --enable-zip \
    --enable-soap \
    --enable-intl \
    --enable-bcmath \
    --enable-mysqlnd \
    --with-mysqli \
    --with-pdo-mysql \
    --with-mysql=/usr \
    --with-mysql-sock=/var/run/mysqld/mysqld.sock \
    --with-curl \
    --with-openssl \
    --with-zlib \
    --with-jpeg-dir \
    --with-png-dir \
    # --with-gd \
    --with-freetype-dir=/usr/include \
    --with-libdir=lib \
    --with-xpm-dir=/usr/lib \
    --with-mcrypt \
    --with-xsl \
    --with-readline \
    --with-icu-dir=/usr \
    --enable-cli \
    --with-apxs2=/usr/bin/apxs && \
    make -j$(nproc) && \
    make install

# Add PHP to PATH
ENV PATH="/usr/local/php5.3/bin:$PATH"

# Configure Apache to use PHP 5.3
COPY config/apache2.conf /etc/apache2/apache2.conf
COPY config/php.ini /usr/local/php5.3/etc/php.ini

# Copy web files and set ownership
COPY www /var/www
RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www

# Expose port 80
EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
