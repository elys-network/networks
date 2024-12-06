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
CHAINID="elysicstestnet-1"
MONIKER="$1"
DENOM="uelys"
DBENGINE="pebbledb"
BLOCKTIME="3s"
VERSION="v0.54.0"

denali="0f9a0d0b74377b6330053131eb31b8e97d527bee@37.27.81.152:26656"
utopia="7f4a326cd0e3942203e5479f550657e09356c73c@135.181.86.200:26656"
nirvana="20407fc4733b0bad9b4f5e74f48a535d210259f8@65.21.116.24:26656"
euphoria="51bfff7ba2bc8ca1e0f99f6411c9642a00ec5c9c@37.187.154.66:26656"
shangrila="30eb3ba6b509890df40276c0d0eb418ecae88279@109.135.1.86:26656"

PEERS="$denali,$utopia,$nirvana,$euphoria,$shangrila"
SEED="$denali"

# Add after variables section
if [ "$MONIKER" = "YOUR_MONIKER" ]; then
    echo "Please set your MONIKER before running this script"
    exit 1
fi

# stop the node
sudo systemctl stop elysd.service

# backup the old elys data if any
if [ -d "$HOME/.elys.bak" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    mv "$HOME/.elys.bak" "$HOME/.elys.bak_$TIMESTAMP"
fi
mv "$HOME/.elys" "$HOME/.elys.bak"

# download the new binary from releases
echo "Downloading Elys binary..."
curl -L https://github.com/elys-network/elys/releases/download/$VERSION/elysd-$VERSION-linux-amd64 -o $HOME/go/bin/elysd || {
    echo "Failed to download binary"
    exit 1
}
chmod +x $HOME/go/bin/elysd

# download the new binary from sources
# cd $HOME && git clone https://github.com/elys-network/elys.git && cd $HOME/elys && git fetch && git checkout $VERSION && git pull origin $VERSION && git tag -f $VERSION && make install

# Verify binary exists after download
if ! command -v elysd &> /dev/null; then
    echo "elysd binary not found after installation"
    exit 1
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

sed -i -E "s|minimum-gas-prices = \".*\"|minimum-gas-prices = \"0.001$DENOM\"|g" $app_toml
sed -i -E '/\[api\]/,/^enable = .*$/ s/^enable = .*$/enable = true/' $app_toml
sed -i -E 's|swagger = .*|swagger = true|g' $app_toml
sed -i -E "s|localhost|0.0.0.0|g" $app_toml
sed -i -E 's|unsafe-cors = .*|unsafe-cors = true|g' $app_toml
sed -i -E "s|app-db-backend = \".*\"|app-db-backend = \"$DBENGINE\"|g" $app_toml

sed -i -E "s|chain-id = \"\"|chain-id = \"$CHAINID\"|g" $client_toml
sed -i -E "s|keyring-backend = \"os\"|keyring-backend = \"test\"|g" $client_toml

curl https://raw.githubusercontent.com/elys-network/networks/refs/heads/main/testnet/$CHAINID/genesis.json -o $genesis_json

# setup cosmovisor
mkdir -p $HOME/.elys/cosmovisor/upgrades/$VERSION/bin && cp -a $HOME/go/bin/elysd $HOME/.elys/cosmovisor/upgrades/$VERSION/bin/elysd && rm -rf $HOME/.elys/cosmovisor/current && ln -sf $HOME/.elys/cosmovisor/upgrades/$VERSION $HOME/.elys/cosmovisor/current

# start the node
sudo systemctl start elysd.service