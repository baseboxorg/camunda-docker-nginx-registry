#!/bin/sh

HTTP_USERNAME=${HTTP_USERNAME:-camunda}
HTTP_PASSWORD=${HTTP_PASSWORD:-camunda}

HTPASSWD_FILE=/etc/nginx/htpasswd/registry

mkdir -p $(dirname $HTPASSWD_FILE)

htpasswd -b -c $HTPASSWD_FILE $HTTP_USERNAME $HTTP_PASSWORD

exec nginx -g "daemon off;"
