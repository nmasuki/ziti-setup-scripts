sudo apt update && sudo apt install jq -y

export EXTERNAL_DNS="threatfend.io"
export EXTERNAL_IP="$(curl -s eth0.me)"       
export ZITI_EDGE_CONTROLLER_IP_OVERRIDE="${EXTERNAL_IP}"
export ZITI_EDGE_ROUTER_IP_OVERRIDE="${EXTERNAL_IP}"
export ZITI_EDGE_CONTROLLER_HOSTNAME="${EXTERNAL_DNS}"
export ZITI_EDGE_ROUTER_HOSTNAME="${EXTERNAL_DNS}"
export ZITI_EDGE_CONTROLLER_PORT=8441
export ZITI_EDGE_ROUTER_PORT=8442

# now download, source, and execute the expressInstall function
source /dev/stdin <<< "$(wget -qO- https://raw.githubusercontent.com/openziti/ziti/release-next/quickstart/docker/image/ziti-cli-functions.sh)"; expressInstall

# Systemd
createControllerSystemdFile
createRouterSystemdFile "${ZITI_EDGE_ROUTER_RAWNAME}"

# Copy  Systemd
sudo cp "${ZITI_HOME}/${ZITI_EDGE_CONTROLLER_RAWNAME}.service" /etc/systemd/system/ziti-controller.service
sudo cp "${ZITI_HOME}/${ZITI_EDGE_ROUTER_RAWNAME}.service" /etc/systemd/system/ziti-router.service
sudo systemctl daemon-reload
sudo systemctl start ziti-controller
sudo systemctl start ziti-router

# Check Systemd status
sudo systemctl -q status ziti-controller --lines=0 --no-pager
sudo systemctl -q status ziti-router --lines=0 --no-pager

# Ziti admin
git clone https://github.com/nmasuki/ziti-console.git "${ZITI_HOME}/ziti-console"
cd "${ZITI_HOME}/ziti-console"
sudo apt install npm nodejs -y
npm install

ln -s "${ZITI_PKI}/${ZITI_EDGE_CONTROLLER_HOSTNAME}-intermediate/certs/${ZITI_EDGE_CONTROLLER_HOSTNAME}-server.chain.pem" "${ZITI_HOME}/ziti-console/server.chain.pem"
ln -s "${ZITI_PKI}/${ZITI_EDGE_CONTROLLER_HOSTNAME}-intermediate/keys/${ZITI_EDGE_CONTROLLER_HOSTNAME}-server.key" "${ZITI_HOME}/ziti-console/server.key"

createZacSystemdFile
sudo cp "${ZITI_HOME}/ziti-console.service" /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start ziti-console

sudo systemctl status ziti-console --lines=0 --no-pager

ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 1280
ufw allow 1408
ufw allow 3022
ufw allow 3023
ufw allow 8441
ufw allow 8442
ufw allow 8444

# make the clients
ziti edge create identity user windowsweb -o windowsweb.jwt
ziti edge create identity device ubuvm -o ubuvm.jwt

# create the host/intercept configs
ziti edge create config sample-web-app-host.v1 host.v1 '{"protocol":"tcp", "address":"sample-web-app","port":8000}'
ziti edge create config sample-web-app-intercept.v1 intercept.v1 '{"protocols":["tcp"],"addresses":["sample-web-app.ziti"], "portRanges":[{"low":8000, "high":8000}]}'

# create the service
ziti edge create service sample-web-app --configs "sample-web-app-intercept.v1","sample-web-app-host.v1"

# create the service policies
ziti edge create service-policy sample-web-app-binding Bind --service-roles '@sample-web-app' --identity-roles '@ubuvm'
ziti edge create service-policy sample-web-app-dialing Dial --service-roles '@sample-web-app' --identity-roles '@windowsweb'
ziti edge create service-policy sample-web-app-dialing Dial --service-roles '@sample-web-app' --identity-roles '@android'