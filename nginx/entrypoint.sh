#!/bin/sh
set -eu

DOMAIN="${DOMAIN:-pandoral.me}"
CERT_DIR="/etc/letsencrypt/live/$DOMAIN"
CERT_KEY="$CERT_DIR/privkey.pem"
CERT_CRT="$CERT_DIR/fullchain.pem"

mkdir -p "$CERT_DIR"

if [ ! -s "$CERT_KEY" ] || [ ! -s "$CERT_CRT" ]; then
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
