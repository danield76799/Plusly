#!/bin/bash

# Plusly Website Setup Script
# Host je GitHub Pages website op je eigen VPS

set -e

# Kleuren
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Plusly Website Setup${NC}"
echo "===================="
echo ""

# Check of je root bent
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Run dit script als root (sudo)${NC}"
    exit 1
fi

# Vraag om domein
read -p "Domeinnaam (bijv. plusly.im of laat leeg voor IP): " DOMAIN

# Installeer Nginx
echo -e "${YELLOW}Nginx installeren...${NC}"
apt update
apt install -y nginx git

# Start en enable Nginx
systemctl start nginx
systemctl enable nginx

# Maak website directory
WEB_DIR="/var/www/plusly"
mkdir -p $WEB_DIR

# Clone de repo (GitHub Pages branch)
echo -e "${YELLOW}Website downloaden...${NC}"
cd $WEB_DIR

# Check of er al een gh-pages branch is
if git ls-remote --heads https://github.com/danield76799/Plusly.git gh-pages | grep -q gh-pages; then
    git clone -b gh-pages https://github.com/danield76799/Plusly.git .
else
    # Anders gebruik de main branch docs folder
    git clone https://github.com/danield76799/Plusly.git /tmp/plusly-repo
    if [ -d "/tmp/plusly-repo/docs" ]; then
        cp -r /tmp/plusly-repo/docs/* $WEB_DIR/
    else
        cp -r /tmp/plusly-repo/* $WEB_DIR/
    fi
    rm -rf /tmp/plusly-repo
fi

# Set correcte permissions
chown -R www-data:www-data $WEB_DIR
chmod -R 755 $WEB_DIR

# Maak Nginx config
if [ -z "$DOMAIN" ]; then
    # Gebruik IP adres
    SERVER_NAME="_"
else
    SERVER_NAME="$DOMAIN"
fi

cat > /etc/nginx/sites-available/plusly << EOF
server {
    listen 80;
    listen [::]:80;
    
    server_name $SERVER_NAME;
    
    root $WEB_DIR;
    index index.html index.htm;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Enable gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    
    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg)$ {
        expires 1M;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable de site
ln -sf /etc/nginx/sites-available/plusly /etc/nginx/sites-enabled/

# Verwijder default site
rm -f /etc/nginx/sites-enabled/default

# Test Nginx config
nginx -t

# Herstart Nginx
systemctl restart nginx

# Open firewall poort 80
ufw allow 80/tcp
ufw allow 443/tcp

echo ""
echo -e "${GREEN}✅ Website is geïnstalleerd!${NC}"
echo ""

if [ -z "$DOMAIN" ]; then
    IP=$(curl -s ifconfig.me)
    echo -e "Je website is bereikbaar op: ${YELLOW}http://$IP${NC}"
else
    echo -e "Je website is bereikbaar op: ${YELLOW}http://$DOMAIN${NC}"
    echo ""
    echo -e "${YELLOW}Let op:${NC} Zorg dat je DNS A-record wijst naar dit IP adres"
fi

echo ""
echo -e "Website locatie: ${YELLOW}$WEB_DIR${NC}"
echo -e "Nginx config: ${YELLOW}/etc/nginx/sites-available/plusly${NC}"
echo ""
echo -e "${GREEN}Om te updaten, run:${NC}"
echo "  cd $WEB_DIR && git pull"
echo ""
