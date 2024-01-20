// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.9;

uint256 constant TOTAL_TICKETS = 10;

contract First_Try {
  address public owner = msg.sender;

  struct Ticket {
    address owner;
    uint256 price;
  }

  Ticket[TOTAL_TICKETS] public tickets;

  constructor() {
    for (uint256 i = 0; i < TOTAL_TICKETS; i++) {
      tickets[i].owner = address(0x0);
      tickets[i].price = 1e17;
    }
  }
  
  function buyTicket(uint256 ticketId) external payable {
    require(ticketId >= 0 && ticketId < TOTAL_TICKETS, "Ticket ID does not exist");
    require(msg.value == tickets[ticketId].price, "Not enough Ether provided");
    require(tickets[ticketId].owner == address(0x0), "Ticket already sold");

    tickets[ticketId].owner = msg.sender;
  }

}


