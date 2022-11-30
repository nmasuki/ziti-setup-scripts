# setup Linux Tunneller in a clients network/server https://openziti.github.io/docs/core-concepts/clients/tunnelers/linux/

# 1. Run the script for your OS to install ziti-edge-tunnel.
curl -sSLf https://raw.githubusercontent.com/openziti/ziti-tunnel-sdk-c/main/package-repos.gpg \
| gpg --dearmor \
| sudo tee /usr/share/keyrings/openziti.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/openziti.gpg] https://packages.openziti.org/zitipax-openziti-deb-stable jammy main' \
| sudo tee /etc/apt/sources.list.d/openziti.list >/dev/null
sudo apt update
sudo apt install ziti-edge-tunnel

# 2. Place an enrollment token JWT file or identity config JSON file in /opt/openziti/etc/identities.
# 3. Enable and start the service
sudo systemctl enable --now ziti-edge-tunnel.service

# 4. The process needs to be restarted if the contents of /opt/openziti/etc/identities change.
sudo systemctl restart ziti-edge-tunnel.service