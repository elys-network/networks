#!/bin/bash

set -e  # Exit on any error

# Check if MONIKER was provided as argument
if [ -z "$1" ]; then
    echo "Error: MONIKER not provided"
    echo "Usage: $0 <moniker>"
    echo "Example: $0 my-validator-node"
    exit 1
fi

# set variables
CHAINID="elys-1"
MONIKER="$1"
DENOM="uelys"
USDC="ibc/F082B65C88E4B6D5EF1DB243CDA1D331D002759E938A0F5CD3FFDC5D53B3E349"
ATOM="ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9"
DBENGINE="pebbledb"
BLOCKTIME="3s"
VERSION="v1.0.0"

zephyr="7e0e2a7a6c435274399d1df9cf65dc4b8b4ebf04@51.89.64.156:26656"
thoth="41defad48e55a1f69753d50a0b9686d03502e3c6@51.89.235.111:26656"
baldur="336b4190e2bbd194509f452ab53f301a361a4349@51.178.89.172:26656"
izanagi="2a899b63889ac5caa4c0219fa37992fa624b79de@51.161.118.222:26656"

PEERS="$zephyr,$thoth,$baldur,$izanagi"
SEED="$zephyr"

# Add after variables section
if [ "$MONIKER" = "YOUR_MONIKER" ]; then
    echo "Please set your MONIKER before running this script"
    exit 1
fi


# create the /etc/systemd/system/elysd.service file if it doesn't exist with the following content
if [ ! -f /etc/systemd/system/elysd.service ]; then
    sudo tee /etc/systemd/system/elysd.service > /dev/null <<EOF
[Unit]
Description=Elys Network Mainnet Node
After=network-online.target

[Service]
User=ubuntu
ExecStart=/home/ubuntu/go/bin/cosmovisor run start
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
Environment="DAEMON_NAME=elysd"
Environment="DAEMON_HOME=/home/ubuntu/.elys"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF
fi

# enable the elysd service
sudo systemctl daemon-reload
sudo systemctl enable elysd.service

# stop the node
sudo systemctl stop elysd.service

# backup the old elys data if any
if [ -d "$HOME/.elys.bak" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    mv "$HOME/.elys.bak" "$HOME/.elys.bak_$TIMESTAMP"
fi
# move the old elys data to the backup folder if there is one
if [ -d "$HOME/.elys" ]; then
    mv "$HOME/.elys" "$HOME/.elys.bak"
fi

# create the $HOME/go/bin folder if it doesn't exist
mkdir -p $HOME/go/bin

# download the new binary from releases
echo "Downloading Elys binary..."
curl -L https://github.com/elys-network/elys/releases/download/$VERSION/elysd-$VERSION-linux-amd64 -o $HOME/go/bin/elysd || {
    echo "Failed to download binary"
    exit 1
}
chmod +x $HOME/go/bin/elysd

# check if $HOME/go/bin is in the PATH otherwise add it to the .bashrc file
if ! echo $PATH | grep -q "$HOME/go/bin"; then
    echo "export PATH=\"$HOME/go/bin:\$PATH\"" >> ~/.bashrc
    export PATH="$HOME/go/bin:$PATH"
    source ~/.bashrc
fi

# download the new binary from sources
# cd $HOME && git clone https://github.com/elys-network/elys.git && cd $HOME/elys && git fetch && git checkout $VERSION && git pull origin $VERSION && git tag -f $VERSION && make install

# Verify binary exists after download
if ! command -v elysd &> /dev/null; then
    echo "elysd binary not found after installation"
    exit 1
fi

# if cosmovisor is not installed, install it
if ! command -v cosmovisor &> /dev/null; then
    echo "cosmovisor not found, installing it..."
    curl -L https://github.com/cosmos/cosmos-sdk/releases/download/cosmovisor%2Fv1.7.0/cosmovisor-v1.7.0-linux-amd64.tar.gz | tar -xz -C $HOME/go/bin cosmovisor && chmod +x $HOME/go/bin/cosmovisor
fi

# init the new node
elysd init $MONIKER --chain-id $CHAINID

# update config files and fetch genesis
config_toml="$HOME/.elys/config/config.toml"
client_toml="$HOME/.elys/config/client.toml"
app_toml="$HOME/.elys/config/app.toml"
genesis_json="$HOME/.elys/config/genesis.json"

sed -i -E "s|cors_allowed_origins = \[\]|cors_allowed_origins = [\"\*\"]|g" $config_toml
sed -i -E "s|db_backend = \".*\"|db_backend = \"$DBENGINE\"|g" $config_toml
sed -i -E "s|127.0.0.1|0.0.0.0|g" $config_toml
sed -i -E "s|timeout_commit = \"5s\"|timeout_commit = \"$BLOCKTIME\"|g" $config_toml
sed -i -E "s|seeds = \".*\"|seeds = \"$SEED\"|g" $config_toml
sed -i -E "s|persistent_peers = \".*\"|persistent_peers = \"$PEERS\"|g" $config_toml

sed -i -E "s|minimum-gas-prices = \".*\"|minimum-gas-prices = \"0.0003$DENOM,0.001$USDC,0.001$ATOM\"|g" $app_toml
sed -i -E '/\[api\]/,/^enable = .*$/ s/^enable = .*$/enable = true/' $app_toml
sed -i -E 's|swagger = .*|swagger = true|g' $app_toml
sed -i -E "s|localhost|0.0.0.0|g" $app_toml
sed -i -E 's|unsafe-cors = .*|unsafe-cors = true|g' $app_toml
sed -i -E "s|app-db-backend = \".*\"|app-db-backend = \"$DBENGINE\"|g" $app_toml

sed -i -E "s|chain-id = \".*\"|chain-id = \"$CHAINID\"|g" $client_toml
sed -i -E "s|keyring-backend = \"os\"|keyring-backend = \"test\"|g" $client_toml

curl https://raw.githubusercontent.com/elys-network/networks/refs/heads/main/mainnet/genesis.json -o $genesis_json

# setup cosmovisor
mkdir -p $HOME/.elys/cosmovisor/upgrades/$VERSION/bin && cp -a $HOME/go/bin/elysd $HOME/.elys/cosmovisor/upgrades/$VERSION/bin/elysd && rm -rf $HOME/.elys/cosmovisor/current && ln -sf $HOME/.elys/cosmovisor/upgrades/$VERSION $HOME/.elys/cosmovisor/current

# start the node
sudo systemctl start elysd.service

# check if the node is running
sudo systemctl status elysd.service

# check logs
sudo journalctl -fu elysd.service -o cat
