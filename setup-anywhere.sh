sudo apt update && sudo apt install jq -y

if [ "ZITI_CLIENT" == ""] then
    if [ "$1" == ""]; then
        echo "Enter client id (Alphanumeric only):"
        read client_name
    elif
        client_name=$1
    fi
    export ZITI_CLIENT=$client_name
fi

export EXTERNAL_DNS="${ZITI_CLIENT}.threatfend.io"
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

ufw allow 3022
ufw allow 3023
ufw allow 8441
ufw allow 8442
ufw allow 8444