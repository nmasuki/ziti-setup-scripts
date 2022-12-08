if [ "$1" == ""]; then
    echo "Enter client id (Alphanumeric only):"
    read client_name
elif
    client_name=$1
fi

export ZITI_CLIENT=$client_name

# Load env variable 
source ~/.ziti/quickstart/${ZITI_CLIENT}/${ZITI_CLIENT}.env

# Ziti admin
git clone https://github.com/nmasuki/ziti-console.git "${ZITI_HOME}/ziti-console"
cd "${ZITI_HOME}/ziti-console"

# Install npm and nodejs
sudo apt update
sudo apt install npm nodejs -y
npm install

# Point to Ziti certificates
ln -s "${ZITI_PKI}/${ZITI_EDGE_CONTROLLER_HOSTNAME}-intermediate/certs/${ZITI_EDGE_CONTROLLER_HOSTNAME}-server.chain.pem" "${ZITI_HOME}/ziti-console/server.chain.pem"
ln -s "${ZITI_PKI}/${ZITI_EDGE_CONTROLLER_HOSTNAME}-intermediate/keys/${ZITI_EDGE_CONTROLLER_HOSTNAME}-server.key" "${ZITI_HOME}/ziti-console/server.key"

# Run ZAC as a service
createZacSystemdFile
sudo cp "${ZITI_HOME}/ziti-console.service" /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start ziti-console

# Check service status
sudo systemctl status ziti-console --lines=0 --no-pager

# open some firewall access
ufw allow 1280
ufw allow 1408