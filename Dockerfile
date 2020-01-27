FROM php:7.3-fpm

# Copy composer.lock and composer.json
#COPY ./code/composer.lock ./code/composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
apt-get update && apt-get install -y \
    nodejs \
    build-essential \
    mariadb-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    libzip-dev \
    git \
    curl&& \
    npm install -g npm

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
#RUN groupadd -g 1000 www-data
#RUN useradd -u 1000 -ms /bin/bash -g www-data www-data

# Copy existing application directory contents
COPY ./code /var/www

# Copy existing application directory permissions
COPY --chown=www-data:www-data ./code /var/www

#RUN chown -R www-data:www-data /var/www

# Change current user to www
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]