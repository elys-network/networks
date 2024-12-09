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