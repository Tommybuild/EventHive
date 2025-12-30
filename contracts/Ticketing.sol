// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * Minimal ticketing contract: basic ERC-721-like behavior to mint tickets
 * - Organizers can create events
 * - Users can buy/mint tickets (payable)
 * This is a compact scaffold for demo and should be audited and extended for production.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

/**
 * Ticketing contract (upgraded):
 * - ERC-721 tickets via OpenZeppelin
 * - Organizers create events with price and max supply
 * - Primary minting collects funds per event
 * - Marketplace/resale: owners can list tickets, buyers can purchase; a resale fee (royalty) is sent to the event organizer
 * - Organizer can withdraw accumulated event proceeds (primary sales + royalties)
 *
 * NOTE: This is a scaffold. Review economic flows, security, and perform an audit before production.
 */
contract Ticketing is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _eventIds;
    Counters.Counter private _tokenIds;

    struct EventInfo {
        address payable organizer;
        string metadataURI;
        uint256 priceWei;
        uint256 maxTickets;
        uint256 minted;
        bool active;
    }

    // eventId => EventInfo
    mapping(uint256 => EventInfo) public events;
    // tokenId => eventId
    mapping(uint256 => uint256) public tokenToEvent;
    // tokenId => listing price (0 = not listed)
    mapping(uint256 => uint256) public listingPrice;
    // eventId => accumulated balance (primary sales + royalties)
    mapping(uint256 => uint256) public eventBalances;

    // Resale fee in basis points (parts per 10,000). Default 500 = 5%.
    uint96 public resaleFeeBps = 500;

    event EventCreated(uint256 indexed eventId, address indexed organizer);
    event TicketMinted(
        uint256 indexed eventId,
        uint256 indexed tokenId,
        address indexed to
    );
    event ListedForSale(uint256 indexed tokenId, uint256 price);
    event Sale(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );
    event Withdraw(address indexed organizer, uint256 eventId, uint256 amount);

    constructor() ERC721("EventHive Ticket", "EHT") {}

    modifier onlyOrganizer(uint256 eventId) {
        require(
            events[eventId].organizer == payable(msg.sender),
            "only organizer"
        );
        _;
    }

    function createEvent(
        string calldata metadataURI,
        uint256 priceWei,
        uint256 maxTickets
    ) external returns (uint256) {
        require(maxTickets > 0, "maxTickets>0");
        _eventIds.increment();
        uint256 eid = _eventIds.current();
        events[eid] = EventInfo({
            organizer: payable(msg.sender),
            metadataURI: metadataURI,
            priceWei: priceWei,
            maxTickets: maxTickets,
            minted: 0,
            active: true
        });
        emit EventCreated(eid, msg.sender);
        return eid;
    }

    /// @notice Primary purchase: mints a new ticket to the buyer and records proceeds for the organizer
    function mintTicket(
        uint256 eventId
    ) external payable nonReentrant returns (uint256) {
        EventInfo storage ev = events[eventId];
        require(ev.active, "event not active");
        require(ev.minted < ev.maxTickets, "sold out");
        require(msg.value >= ev.priceWei, "insufficient payment");

        _tokenIds.increment();
        uint256 tid = _tokenIds.current();
        _safeMint(msg.sender, tid);
        // assign token URI to event metadata by default
        _setTokenURI(tid, ev.metadataURI);
        tokenToEvent[tid] = eventId;
        ev.minted++;

        // credit organizer with the primary sale proceeds
        eventBalances[eventId] += ev.priceWei;

        // refund any overpayment
        if (msg.value > ev.priceWei) {
            payable(msg.sender).transfer(msg.value - ev.priceWei);
        }

        emit TicketMinted(eventId, tid, msg.sender);
        return tid;
    }

    /// @notice List a ticket for sale at `price` (wei). Owner must call.
    function listForSale(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        require(price > 0, "price>0");
        listingPrice[tokenId] = price;
        emit ListedForSale(tokenId, price);
    }

    /// @notice Cancel a listing
    function cancelListing(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        listingPrice[tokenId] = 0;
        emit ListedForSale(tokenId, 0);
    }

    /// @notice Buy a listed ticket; pays seller and sends royalty to event organizer
    function buy(uint256 tokenId) external payable nonReentrant {
        uint256 price = listingPrice[tokenId];
        require(price > 0, "not for sale");
        require(msg.value >= price, "insufficient payment");

        address seller = ownerOf(tokenId);
        require(seller != msg.sender, "cannot buy own");

        // clear listing
        listingPrice[tokenId] = 0;

        // compute fee and payouts
        uint256 fee = (uint256(price) * uint256(resaleFeeBps)) / 10000;
        uint256 sellerAmount = price - fee;

        // transfer the token
        _transfer(seller, msg.sender, tokenId);

        // pay seller
        (bool okSeller, ) = payable(seller).call{value: sellerAmount}("");
        require(okSeller, "seller transfer failed");

        // credit organizer with royalty fee
        uint256 eventId = tokenToEvent[tokenId];
        eventBalances[eventId] += fee;

        // refund any overpayment to buyer
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }

        emit Sale(tokenId, seller, msg.sender, price);
    }

    /// @notice Organizer withdraws accumulated funds for an event
    function withdraw(
        uint256 eventId,
        address payable to
    ) external onlyOrganizer(eventId) nonReentrant {
        uint256 amount = eventBalances[eventId];
        require(amount > 0, "no funds");
        eventBalances[eventId] = 0;
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "withdraw failed");
        emit Withdraw(msg.sender, eventId, amount);
    }

    /// @notice Owner can update resale fee
    function setResaleFeeBps(uint96 bps) external onlyOwner {
        require(bps <= 2000, "fee too high"); // max 20%
        resaleFeeBps = bps;
    }

    // receive fallback in case ETH is sent directly
    receive() external payable {}
    fallback() external payable {}
}
