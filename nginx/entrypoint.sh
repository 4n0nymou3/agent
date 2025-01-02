#!/bin/sh

NGINX_CONF_PATH=/etc/nginx/nginx.conf

sed -i "s|\${NGINX_FAKE_WEBSITE}|$NGINX_FAKE_WEBSITE|g" "$NGINX_CONF_PATH"
sed -i "s|\${NGINX_PATH}|$NGINX_PATH|g" "$NGINX_CONF_PATH"

# xray-config upstream URL
UPSTREAM_URL="http://xray-config:5000/subdomain"

# Perform a GET request to the upstream
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$UPSTREAM_URL")

# Check the HTTP status code of xray-config upstream
if [ "$RESPONSE" -eq 200 ]; then
    echo "xray-config is ready: $UPSTREAM_URL"
else
    echo "xray-config is not ready yet: $UPSTREAM_URL (HTTP status: $RESPONSE)"
    sleep 5
    exit 1
fi

DIRECT_SUBDOMAIN=$(curl -s "$UPSTREAM_URL")

sed -i "s|\${DIRECT_SUBDOMAIN}|$DIRECT_SUBDOMAIN|g" "$NGINX_CONF_PATH"

nginx -g "daemon off;"