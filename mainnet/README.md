# Joining the Elys Mainnet (ICS)

Welcome to the Elys mainnet! This guide will help you set up a full node and join the mainnet. The producer chain is the Cosmos Hub, and this mainnet ensures compatibility and stability for the Interchain Security (ICS) environment.

## Quick Reference

- Consumer ID: 21
- Chain ID: elys-1

## Hardware Requirements

| Component | Minimum Specification |
| --------- | --------------------- |
| CPU       | 8 cores               |
| RAM       | 32 GB                 |
| Storage   | 500 GB SSD            |
| Network   | 100 Mbps+             |

## Software Requirements

- **Operating System**: Ubuntu 20.04+ or macOS
- **Go**: v1.22.6

## Validator Setup Instructions

### 1. Opt-In to Consumer Chain (Validators Only)

```bash
gaiad tx provider opt-in 21 \
    --from [YOUR_KEY] \
    --chain-id cosmoshub-4 \
    --fees 2000uatom \
    --node https://cosmos-rpc.publicnode.com:443
```

### 2. Node Setup Options

#### Option A: Quick Setup Script

```bash
wget https://raw.githubusercontent.com/elys-network/networks/main/mainnet/create_node.sh
chmod +x create_node.sh
./create_node.sh "your-moniker-name"
```

> **⚠️ Important Note for Validators**:
>
> 1. Before running the script, ensure it does not automatically start the node (check and modify the script if needed)
> 2. After running the script, you must replace the `$HOME/.elys/config/priv_validator_key.json` with your cosmos's provider mainnet `priv_validator_key.json` file
> 3. Only start the node after completing the key replacement to avoid double signing

#### Option B: Manual Setup

1. **Clone and Build**

```bash
git clone https://github.com/elys-network/elys.git
cd elys
git checkout v1.0.0
make install
elysd init [your-moniker] --chain-id elys-1
```

2. **Configure Node**

a. Download Genesis File

```bash
curl -o $HOME/.elys/config/genesis.json https://raw.githubusercontent.com/elys-network/networks/refs/heads/main/mainnet/genesis.json
```

b. **For Validators**: Replace Validator Key

- Replace `$HOME/.elys/config/priv_validator_key.json` with your cosmoshub's mainnet key
- Alternative key delegation instructions available [here](https://github.com/cosmos/testnets/blob/master/interchain-security/VALIDATOR_JOINING_GUIDE.md#option-two-use-key-delegation)

c. Configure Node Settings

- Add persistent peers and seeds in `config.toml`
- Set minimum gas prices in `app.toml`:

```
minimum-gas-prices = "0.0003uelys,0.001ibc/F082B65C88E4B6D5EF1DB243CDA1D331D002759E938A0F5CD3FFDC5D53B3E349,0.001ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9"
```

c. **For Governors**: Run those commands to register as a governor

- Retrieve the governor pubkey:

  ```
  elysd cometbft show-validator
  ```

- Create the governor.json file:

```bash
cat <<EOF > /tmp/governor.json
{
	"pubkey": [PUBKEY],
	"amount": "10000000uelys",
	"moniker": "[MONIKER]",
	"identity": "Elys Mainnet Governor",
	"website": "https://elys.network",
	"security": "team@elys.network",
	"details": "validator's (optional) details",
	"commission-rate": "0.1",
	"commission-max-rate": "0.2",
	"commission-max-change-rate": "0.01",
	"min-self-delegation": "1"
}
EOF
```

- Create the governor:

```bash
elysd tx staking create-validator \
    /tmp/governor.json \
    --from [YOUR_KEY] \
    --chain-id elys-1 \
    --fees 20000uelys \
    --gas auto
```

### 3. Running the Node

#### Option A: Direct Start

```bash
elysd start
```

#### Option B: System Service (Recommended)

1. Create Service File

```bash
sudo nano /etc/systemd/system/elysd.service
```

2. Add Service Configuration

```ini
[Unit]
Description=Elys Network Mainnet Node
After=network.target

[Service]
User=[user]
ExecStart=$(which elysd) start
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

3. Enable and Manage Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable elysd

# Start node
sudo systemctl start elysd

# Stop node
sudo systemctl stop elysd

# Check logs
sudo journalctl -u elysd -f -o cat
```

## IBC Connection Infos:

```
# Chain: cosmoshub-4
- Client: 07-tendermint-1339
    * Connection: connection-1073
        + Channel: channel-1265
            | Port: provider
            | Counterparty: channel-0
        + Channel: channel-1266
            | Port: transfer
            | Counterparty: channel-1

# Chain: elys-1
- Client: 07-tendermint-0 [Atom]
    * Connection: connection-1
        + Channel: channel-0
            | Port: consumer
            | Counterparty: channel-1265
        + Channel: channel-1
            | Port: transfer
            | Counterparty: channel-1266
- Client: 07-tendermint-3 [Noble]
    * Connection: connection-2
        + Channel: channel-2
            | Port: transfer
            | Counterparty: channel-117
- Client: 07-tendermint-4 [Axelar]
    * Connection: connection-3
        + Channel: channel-3
            | Port: transfer
            | Counterparty: channel-163
- Client: 07-tendermint-5 [Celestia]
    * Connection: connection-4
        + Channel: channel-4
            | Port: transfer
            | Counterparty: channel-50
- Client: 07-tendermint-6 [akashnet-2]
    * Connection: connection-5
        + Channel: channel-5
            | Port: transfer
            | Counterparty: channel-129

# Chain: noble-1
- Client: 07-tendermint-133
    * Connection: connection-130
        + Channel: channel-117
            | Port: transfer
            | Counterparty: channel-2

# Chain: axelar-dojo-1
- Client: 07-tendermint-231
    * Connection: connection-222
        + Channel: channel-163
            | Port: transfer
            | Counterparty: channel-3

# Chain: celestia
- Client: 07-tendermint-95
    * Connection: connection-65
        + Channel: channel-50
            | Port: transfer
            | Counterparty: channel-4

# Chain: akashnet-2
    - Client: 07-tendermint-191
        * Connection: connection-177
            + Channel: channel-129
                | Port: transfer
                | Counterparty: channel-5
    #elys-osmosis:
        src:
            chain-id: elys-1
            client-id: 07-tendermint-7
            connection-id: connection-6
        dst:
            chain-id: osmosis-1
            client-id: 07-tendermint-3377
            connection-id: connection-2833
```
