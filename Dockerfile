FROM nginx:1.27-alpine

RUN apk add --no-cache openssl

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/entrypoint.sh /entrypoint.sh
COPY . /usr/share/nginx/html

RUN chmod +x /entrypoint.sh

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1

CMD ["/entrypoint.sh"]
