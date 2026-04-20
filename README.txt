This is my Frankenstein. Enjoy it.

Production run with Nginx + Let's Encrypt (Docker):

0) DNS and server:
   - Point A records to your VPS IP:
     pandoral.me -> <your_server_ip>
     www.pandoral.me -> <your_server_ip>
   - Open ports 80 and 443 in firewall/security group.

1) Start Nginx:
   docker compose up --build -d site

2) Issue Let's Encrypt certificate (replace email):
   docker compose run --rm certbot certonly --webroot -w /var/www/certbot -d pandoral.me -d www.pandoral.me --email you@example.com --agree-tos --no-eff-email

3) Restart site to switch from fallback cert to Let's Encrypt:
   docker compose restart site

4) Start auto-renew service:
   docker compose up -d certbot

5) Open:
   https://pandoral.me
   https://www.pandoral.me

6) Stop:
   docker compose down

Notes:
- On first start, site service creates a short-lived fallback self-signed cert, so Nginx can boot before Let's Encrypt is issued.
- If cert issuance fails after older setup, remove old certbot state and issue cert again:
  rm -rf ./certbot/conf/live/pandoral.me ./certbot/conf/archive/pandoral.me ./certbot/conf/renewal/pandoral.me.conf
- If your domain is not pandoral.me, update:
  - docker-compose.yml: DOMAIN and certbot -d flags
  - nginx/default.conf: server_name