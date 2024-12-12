# Elys Network Chain Configuration

This repository contains the official chain configurations and setup instructions for the Elys Network chains, including testnet and mainnet (when available).

## Active Networks

### Testnet

- **Chain ID**: elysicstestnet-1
- **Status**: Active
- **Type**: ICS Consumer Chain (Cosmos Hub)
- [Setup Instructions](testnet/elysicstestnet-1/README.md)

### Mainnet

- **Chain ID**: elys-1
- **Status**: Active
- **Type**: ICS Consumer Chain (Cosmos Hub)
- [Setup Instructions](mainnet/README.md)

## Repository Structure

```
networks/
├── testnet/
│   └── elysicstestnet-1/
│       ├── README.md         # Setup instructions and chain information
│       ├── create_node.sh    # Automated node setup script
│       └── genesis.json      # Chain genesis file
├── mainnet/
│       ├── README.md         # Setup instructions and chain information
│       ├── create_node.sh    # Automated node setup script
│       └── genesis.json      # Chain genesis file
└── README.md                 # This file
```

## Quick Start

To join one of the networks, follow these steps:

1. Clone this repository:

```bash
git clone https://github.com/elys-network/networks.git
cd networks
```

2. Navigate to the desired network directory and follow the setup instructions in the respective README.md file.

## Support

- [Discord](https://discord.gg/elys-network)
- [Documentation](https://docs.elys.network)
- [Website](https://elys.network)

## Contributing

If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.
