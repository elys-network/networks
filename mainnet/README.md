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
- Client: 07-tendermint-0
    * Connection: connection-1
        + Channel: channel-0
            | Port: consumer
            | Counterparty: channel-1265
        + Channel: channel-1
            | Port: transfer
            | Counterparty: channel-1266
```
