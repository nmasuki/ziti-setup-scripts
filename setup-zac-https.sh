# Setup nginx
sudo apt update
sudo apt install nginx -y

# Checkout some scripts
git clone https://github.com/nmasuki/ziti-setup-scripts.git "${ZITI_HOME}/treatfend-scripts"
cd "${ZITI_HOME}/treatfend-scripts"

# nginx site config
cp ./nginx-config /etc/nginx/sites-enabled/${EXTERNAL_DNS}
sed -i "1s/.*/server_name $EXTERNAL_DNS;/" /etc/nginx/sites-enabled/${EXTERNAL_DNS}

# open http and https ports
ufw allow 80
ufw allow 443

#Setup https (https://certbot.eff.org/instructions?ws=nginx&os=ubuntubionic)
sudo snap install core; sudo snap refresh core

sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx

# Test automatic renewal
sudo certbot renew --dry-run