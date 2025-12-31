// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/Ticketing.sol";

contract TicketingTest is Test {
    Ticketing ticketing;
    address organizer = address(0x1);
    address buyer = address(0x2);
    address buyer2 = address(0x3);

    function setUp() public {
        ticketing = new Ticketing();
    }

    function testCreateEventAndMint() public {
        // create event
        vm.prank(organizer);
        uint256 eventId = ticketing.createEvent("ipfs://meta", 0.1 ether, 10);

        // buyer mints
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        uint256 tid = ticketing.mintTicket{value: 0.1 ether}(eventId);

        assertEq(ticketing.ownerOf(tid), buyer);
        assertEq(ticketing.balanceOf(buyer), 1);
        assertEq(ticketing.eventBalances(eventId), 0.1 ether);
    }

    function testListAndResell() public {
        vm.prank(organizer);
        uint256 eventId = ticketing.createEvent("ipfs://meta", 0.1 ether, 10);

        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        uint256 tid = ticketing.mintTicket{value: 0.1 ether}(eventId);

        // buyer lists ticket
        vm.prank(buyer);
        ticketing.listForSale(tid, 0.5 ether);

        // buyer2 purchases
        vm.deal(buyer2, 1 ether);
        uint256 sellerBalBefore = buyer.balance;
        vm.prank(buyer2);
        ticketing.buy{value: 0.5 ether}(tid);

        // ownership transferred
        assertEq(ticketing.ownerOf(tid), buyer2);

        // seller received net proceeds (price - fee)
        uint256 feeBps = ticketing.resaleFeeBps();
        uint256 expectedSeller = (0.5 ether * (10000 - feeBps)) / 10000;
        assertEq(buyer.balance - sellerBalBefore, expectedSeller);

        // organizer received fee credited to eventBalances
        uint256 eventFee = ticketing.eventBalances(eventId);
        uint256 expectedFee = (0.5 ether * feeBps) / 10000;
        assertEq(eventFee, expectedFee);
    }

    function testOrganizerWithdraw() public {
        vm.prank(organizer);
        uint256 eventId = ticketing.createEvent("ipfs://meta", 0.1 ether, 10);

        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        ticketing.mintTicket{value: 0.1 ether}(eventId);

        uint256 before = organizer.balance;
        vm.prank(organizer);
        ticketing.withdraw(eventId, payable(organizer));
        assertEq(organizer.balance - before, 0.1 ether);
        assertEq(ticketing.eventBalances(eventId), 0);
    }
}
