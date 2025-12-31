# Frontend

This is a Vite + React frontend. It includes a simple WalletConnect login flow (Web3Modal) and a basic UI to call the Ticketing contract.

Setup

```bash
cd frontend
npm install
npm run dev
```

Environment

- `VITE_RPC_URL` - RPC for WalletConnect (Base mainnet recommended)
- `VITE_CONTRACT_ADDRESS` - deployed Ticketing contract address
- `VITE_REOWN_API_KEY` - (optional) Reown AppKit API key

Reown AppKit

1. Install the official Reown AppKit per their docs. If the package name is `reown-appkit`, you can:

```bash
cd frontend
npm install reown-appkit
```

2. Set `VITE_REOWN_API_KEY` in your environment or `.env` and restart the dev server.

The frontend will attempt to dynamically import `reown-appkit` and fall back to `window.Reown` if provided via a script tag.
