// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * Minimal ticketing contract: basic ERC-721-like behavior to mint tickets
 * - Organizers can create events
 * - Users can buy/mint tickets (payable)
 * This is a compact scaffold for demo and should be audited and extended for production.
 */
contract Ticketing {
    uint256 public nextEventId;
    uint256 public nextTokenId;

    struct EventInfo {
        address organizer;
        string metadataURI; // generic metadata for event
        uint256 priceWei;
        uint256 maxTickets;
        uint256 minted;
        bool active;
    }

    mapping(uint256 => EventInfo) public events;

    // Basic ERC-721 storage (minimal)
    mapping(uint256 => address) private _ownerOf;
    mapping(address => uint256) private _balanceOf;

    event EventCreated(uint256 indexed eventId, address indexed organizer);
    event TicketMinted(
        uint256 indexed eventId,
        uint256 indexed tokenId,
        address indexed to
    );
    event Withdraw(address indexed to, uint256 amount);

    modifier onlyOrganizer(uint256 eventId) {
        require(events[eventId].organizer == msg.sender, "only organizer");
        _;
    }

    function createEvent(
        string calldata metadataURI,
        uint256 priceWei,
        uint256 maxTickets
    ) external returns (uint256) {
        require(maxTickets > 0, "maxTickets>0");
        uint256 eid = ++nextEventId;
        events[eid] = EventInfo({
            organizer: msg.sender,
            metadataURI: metadataURI,
            priceWei: priceWei,
            maxTickets: maxTickets,
            minted: 0,
            active: true
        });
        emit EventCreated(eid, msg.sender);
        return eid;
    }

    function mintTicket(uint256 eventId) external payable returns (uint256) {
        EventInfo storage ev = events[eventId];
        require(ev.active, "event not active");
        require(ev.minted < ev.maxTickets, "sold out");
        require(msg.value >= ev.priceWei, "insufficient payment");

        uint256 tid = ++nextTokenId;
        _ownerOf[tid] = msg.sender;
        _balanceOf[msg.sender]++;
        ev.minted++;
        emit TicketMinted(eventId, tid, msg.sender);
        return tid;
    }

    function balanceOf(address owner) external view returns (uint256) {
        return _balanceOf[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return _ownerOf[tokenId];
    }

    // Simple transfer (no approvals) - for demonstration only
    function transferFrom(address from, address to, uint256 tokenId) external {
        require(_ownerOf[tokenId] == from, "not owner");
        require(msg.sender == from, "only owner can transfer");
        _ownerOf[tokenId] = to;
        _balanceOf[from]--;
        _balanceOf[to]++;
    }

    // Organizer withdraw funds
    function withdraw(
        uint256 eventId,
        address payable to
    ) external onlyOrganizer(eventId) {
        uint256 amount = address(this).balance;
        require(amount > 0, "no funds");
        to.transfer(amount);
        emit Withdraw(to, amount);
    }

    // Fallbacks
    receive() external payable {}
    fallback() external payable {}
}
