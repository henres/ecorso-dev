FROM henres/php-fpm-composer:7.2-xdebug-postgres

USER root

ARG USER_ID

RUN kill -USR2 1
RUN usermod -u $USER_ID www-data

USER www-data
