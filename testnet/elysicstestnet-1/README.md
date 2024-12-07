# Joining the Elys Testnet (ICS)

Welcome to the Elys testnet! This guide will help you set up a full node and join the testnet. The producer chain is the Cosmos Hub, and this testnet ensures compatibility and stability for the Interchain Security (ICS) environment.

## Quick Reference

- Consumer ID: 113
- Chain ID: elysicstestnet-1

## Hardware Requirements

| Component | Minimum Specification |
| --------- | --------------------- |
| CPU       | 8 cores               |
| RAM       | 16 GB                 |
| Storage   | 200 GB SSD            |
| Network   | 100 Mbps+             |

## Software Requirements

- **Operating System**: Ubuntu 20.04+ or macOS
- **Go**: v1.22.6

## Validator Setup Instructions

### 1. Opt-In to Consumer Chain (Validators Only)

```bash
gaiad tx provider opt-in 113 \
    --from [YOUR_KEY] \
    --chain-id provider \
    --fees 2000uatom \
    --node https://rpc.provider-sentry-01.ics-testnet.polypore.xyz:443
```

### 2. Node Setup Options

#### Option A: Quick Setup Script

```bash
wget https://raw.githubusercontent.com/elys-network/networks/main/testnet/elysicstestnet-1/create_node.sh
chmod +x create_node.sh
./create_node.sh "your-moniker-name"
```

> **⚠️ Important Note for Validators**:
>
> 1. Before running the script, ensure it does not automatically start the node (check and modify the script if needed)
> 2. After running the script, you must replace the `$HOME/.elys/config/priv_validator_key.json` with your cosmos's provider testnet `priv_validator_key.json` file
> 3. Only start the node after completing the key replacement to avoid double signing

#### Option B: Manual Setup

1. **Clone and Build**

```bash
git clone https://github.com/elys-network/elys.git
cd elys
git checkout v0.54.0
make install
elysd init [your-moniker] --chain-id elysicstestnet-1
```

2. **Configure Node**

a. Download Genesis File

```bash
curl -o $HOME/.elys/config/genesis.json https://raw.githubusercontent.com/elys-network/networks/refs/heads/main/testnet/elysicstestnet-1/genesis.json
```

b. **For Validators**: Replace Validator Key

- Replace `$HOME/.elys/config/priv_validator_key.json` with your cosmos's provider testnet key
- Alternative key delegation instructions available [here](https://github.com/cosmos/testnets/blob/master/interchain-security/VALIDATOR_JOINING_GUIDE.md#option-two-use-key-delegation)

c. Configure Node Settings

- Add persistent peers and seeds in `config.toml`
- Set minimum gas prices in `app.toml`:

```
minimum-gas-prices = "0.0003uelys,0.001ibc/F082B65C88E4B6D5EF1DB243CDA1D331D002759E938A0F5CD3FFDC5D53B3E349,0.001ibc/C4CFF46FD6DE35CA4CF4CE031E643C8FDC9BA4B99AE598E9B0ED98FE3A2319F9"
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
Description=Elys Network Testnet Node
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
# Chain: provider
- Client: 07-tendermint-186
    * Connection: connection-141
        + Channel: channel-289
        | Port: provider
        | Counterparty: channel-0
        + Channel: channel-290
        | Port: transfer
        | Counterparty: channel-1

# Chain: elysicstestnet-1
- Client: 07-tendermint-0
    * Connection: connection-0
        + Channel: channel-0
        | Port: consumer
        | Counterparty: channel-289
        + Channel: channel-1
        | Port: transfer
        | Counterparty: channel-290
- Client: 07-tendermint-1
- Client: 07-tendermint-2
    * Connection: connection-1
        + Channel: channel-2
        | Port: transfer
        | Counterparty: channel-287

# Chain: grand-1
- Client: 07-tendermint-361
- Client: 07-tendermint-362
    * Connection: connection-331
        + Channel: channel-287
        | Port: transfer
        | Counterparty: channel-2
```
