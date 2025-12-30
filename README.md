# EventHive — Decentralized Event Ticketing

This repo is a starter scaffold for a decentralized event ticketing platform using:

- Smart contracts: Foundry (Solidity)
- Frontend: React + Vite
- Wallet login: WalletConnect (Web3Modal) + placeholder integration for Reown AppKit
- Target network for deployment: Base (mainnet)

Quick start

1. Clone the repo
2. Smart contracts (Foundry):

```bash
# install foundry: https://book.getfoundry.sh/
forge install
# compile
forge build
# run the deploy script (example):
export BASE_RPC_URL="https://mainnet.base.org"
export PRIVATE_KEY="your_deployer_private_key"
forge script script/Deploy.s.sol:DeployScript --rpc-url $BASE_RPC_URL --broadcast
```

3. Frontend (React + Vite)

```bash
cd frontend
npm install
npm run dev
```

Environment variables are shown in `.env.example` files.

Notes

- This is a scaffold. Replace placeholder keys, review security, add tests, and audit before production deploy.

# EventHive
