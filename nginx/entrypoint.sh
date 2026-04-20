#!/bin/sh
set -eu

DOMAIN="${DOMAIN:-pandoral.me}"
LE_CERT_DIR="/etc/letsencrypt/live/$DOMAIN"
NGINX_CERT_DIR="/etc/nginx/certs"
CERT_KEY="$NGINX_CERT_DIR/site.key"
CERT_CRT="$NGINX_CERT_DIR/site.crt"

mkdir -p "$NGINX_CERT_DIR"

if [ -s "$LE_CERT_DIR/privkey.pem" ] && [ -s "$LE_CERT_DIR/fullchain.pem" ]; then
    echo "Let's Encrypt cert found for $DOMAIN. Linking into Nginx cert path..."
    ln -sf "$LE_CERT_DIR/privkey.pem" "$CERT_KEY"
    ln -sf "$LE_CERT_DIR/fullchain.pem" "$CERT_CRT"
elif [ ! -s "$CERT_KEY" ] || [ ! -s "$CERT_CRT" ]; then
    echo "Let's Encrypt cert not found. Generating fallback self-signed cert for $DOMAIN..."
    if ! openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout "$CERT_KEY" \
        -out "$CERT_CRT" \
        -days 7 \
        -subj "/CN=$DOMAIN" \
        -addext "subjectAltName=DNS:$DOMAIN,DNS:www.$DOMAIN"; then
        # Fallback for environments where -addext is unavailable.
        openssl req -x509 -nodes -newkey rsa:2048 \
            -keyout "$CERT_KEY" \
            -out "$CERT_CRT" \
            -days 7 \
            -subj "/CN=$DOMAIN"
    fi
fi

exec nginx -g "daemon off;"
