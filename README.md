# Event NFT Ticketing Platform

A decentralized event management and ticketing system built on Ethereum using ERC-721 NFTs. This project enables organizers to create events and issue NFT-based tickets, while users can securely purchase, transfer, and verify tickets on-chain.

---

## Overview

The Event NFT Ticketing Platform consists of two core smart contracts:

* **EventTicket** – An ERC-721 NFT contract representing tickets for a single event.
* **EventFactory** – A factory contract that deploys new EventTicket contracts for organizers.

Each event is isolated in its own smart contract, ensuring clean separation of state, ownership, and ticket supply.

---

## Key Features

### For Organizers

* Create events with custom metadata (name, date, location, description)
* Define ticket price and maximum ticket supply
* Mint NFT tickets automatically on purchase
* Withdraw ticket sale proceeds
* Mark tickets as used (entry validation)

### For Attendees

* Purchase single or multiple tickets
* Receive tickets as ERC-721 NFTs
* Transfer tickets freely before use
* Verify ticket ownership on-chain

### Platform

* Factory pattern for scalable event creation
* Fully compatible with OpenZeppelin v5
* Solidity ^0.8.x with modern security defaults

---

## Smart Contracts

### EventFactory

Responsible for deploying new EventTicket contracts.

**Responsibilities:**

* Create new events
* Track all deployed events
* Track events by organizer

**Key Functions:**

* `createEvent(...)` – Deploy a new event contract
* `getAllEvents()` – List all events
* `getOrganizerEvents(address)` – List events created by an organizer
* `getEventsPaginated(offset, limit)` – Paginated event discovery

---

### EventTicket

ERC-721 NFT contract representing tickets for a single event.

**Responsibilities:**

* Mint NFT tickets
* Enforce max ticket supply
* Track used tickets
* Handle ticket transfers
* Manage ticket sale funds

**Key Functions:**

* `mintTicket()` – Buy one ticket
* `mintTickets(uint256 quantity)` – Buy multiple tickets
* `useTicket(uint256 tokenId)` – Mark ticket as used (organizer only)
* `getUserTickets(address)` – Fetch tickets owned by a user
* `withdraw()` – Withdraw ticket sale proceeds

---

## Ticket Lifecycle

1. Organizer creates an event via `EventFactory`
2. Users purchase tickets (NFTs are minted)
3. Tickets can be transferred freely
4. Organizer validates entry by calling `useTicket(tokenId)`
5. Used tickets cannot be reused

---

## Security Considerations

* Built on Solidity ^0.8.x (overflow checks enabled)
* Uses OpenZeppelin v5 audited contracts
* Organizer-only access for sensitive operations
* Ticket usage tracked on-chain to prevent reuse
* Ether transfers use `call` (not `transfer`)

---

## Development Setup

### Prerequisites

* Node.js >= 18
* Foundry or Hardhat
* Solidity ^0.8.20

### Install Dependencies

```bash
npm install
```

or

```bash
forge install
```

---

## Compile Contracts

### Hardhat

```bash
npx hardhat compile
```

### Foundry

```bash
forge build
```

---

## Deployment

Deploy `EventFactory` first. Each event will be deployed automatically via the factory.

```solidity
EventFactory factory = new EventFactory(platformWallet);
```

---

## Example Use Cases

* Conferences & Meetups
* Concerts & Festivals
* Web3 Hackathons
* Private Community Events
* DAO Governance Events

---

## Roadmap

* Secondary marketplace integration
* QR-code based ticket scanning
* Off-chain metadata hosting
* Multi-chain deployments
* Royalty support (ERC-2981)

---

## License

MIT License

---

## Disclaimer

This project is provided as-is and has not been audited. Use at your own risk. Always conduct a professional security audit before deploying to mainnet.
