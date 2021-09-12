#!/bin/sh

set -e
cd /tt-rss

while ! pg_isready -h $TTRSS_DB_HOST -U $TTRSS_DB_USER > /dev/null; do
	echo waiting until $TTRSS_DB_HOST is ready...
	sleep 1
done
if [ "$1" = "update" ]; then
	cd /tt-rss
	/usr/bin/php /tt-rss/update_daemon2.php
else
	/usr/bin/uwsgi \
		--chdir /tt-rss \
		--master \
		--http-socket 0.0.0.0:9000 \
		--plugins http,0:php \
		--php-docroot /tt-rss \
		--php-index index.php \
		--mime-file /etc/mime.types \
		--check-static /tt-rss \
		--static-skip-ext .php
fi

