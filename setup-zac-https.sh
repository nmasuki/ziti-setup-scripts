#!/bin/sh
if [ "$ZITI_CLIENT" == "" ]; then
    client_name=$1
    if ["$1" == ""]; then
        echo "Enter client id (Alphanumeric only):"
        read client_name
    fi

    export ZITI_CLIENT=$client_name
fi

# Load env variable 
source ~/.ziti/quickstart/${ZITI_CLIENT}/${ZITI_CLIENT}.env

# Checkout some scripts
git clone https://github.com/nmasuki/ziti-setup-scripts.git "${ZITI_HOME}/treatfend-scripts"
git pull
cd "${ZITI_HOME}/treatfend-scripts"

source"$(wget -qO- https://raw.githubusercontent.com/openziti/ziti/release-next/quickstart/docker/image/ziti-cli-functions.sh)"

# Setup nginx
sudo apt update
sudo apt install nginx -y

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