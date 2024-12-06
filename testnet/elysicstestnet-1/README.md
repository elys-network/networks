# Joining the Elys Testnet (ICS)

Welcome to the Elys testnet! This guide will help you set up a full node and join the testnet. The producer chain is the Cosmos Hub, and this testnet ensures compatibility and stability for the Interchain Security (ICS) environment.

---

## Minimum Hardware Requirements

To run your node effectively, ensure your machine meets the following requirements:

- **CPU**: 8 cores
- **RAM**: 16 GB
- **Disk**: 200 GB SSD
- **Network**: High-speed internet connection with at least 100 Mbps bandwidth

---

## Software Requirements

- **Operating System**: Linux (Ubuntu 20.04 or later recommended) or macOS
- **Go**: v1.22.6

---

## Instructions to Join the Testnet

#### Opt In [Required only for Validators]

Consumer ID: 113
Chain ID: elysicstestnet-1

```
gaiad tx provider opt-in 113 --from [YOUR_KEY] --chain-id provider --fees 2000uatom --node https://rpc.provider-sentry-01.ics-testnet.polypore.xyz:443
```

### 1. Clone the Repository

Download the consumer chain codebase:

```bash
git clone https://github.com/elys-network/elys.git
cd elys
git checkout v0.54.0
make install
elysd init [your-moniker] --chain-id elysicstestnet-1
```

### 2. Starting the node:

#### a. Fetch the genesis file
```
curl -o $HOME/.elys/config/genesis.json https://raw.githubusercontent.com/elys-network/networks/refs/heads/main/testnet/elysicstestnet-1/genesis.json
```
#### b. [Required only for Validators] Replace `$HOME/.elys/config/priv_validator_key.json` with your cosmos's provider testnet `priv_validator_key.json` Note: You can also use another priv_validator_key.json The instructions for it can be found [here](https://github.com/cosmos/testnets/blob/master/interchain-security/VALIDATOR_JOINING_GUIDE.md#option-two-use-key-delegation).

#### c. Add persistent peers and seeds in config.toml

#### d. Set the minimum gas prices in the app.toml file. Recommended 0.001uelys
You can use USDC ibc token as well once the relayer is set up and denom is known

#### e. Start the node: `elysd start`

#### f. Recommended to use systemctl service to run the node:

```
sudo nano /etc/systemd/system/elysd.service
```
Paste the following:

```
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

After exiting the editor:
```
sudo systemctl daemon-reload
sudo systemctl enable elysd
```

To start: `sudo systemctl start elysd`
To stop : `sudo systemctl stop elysd`


#### IBC Connection Infos:
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