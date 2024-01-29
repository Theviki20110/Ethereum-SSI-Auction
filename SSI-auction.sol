// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.9;

contract SSI {
    /*
        Ciascun utente punta ad un compito non assegnato quindi map(string => address):
        se l'indirizzo è valido allora il compito è assegnato altrimenti si accettano
        le puntate dagli utenti.
        
        Ogni utente punta il più piccolo incremento in termini di distanza che avrebbe
        vincendo il task (considerando i task già presi).
        
        Vince quello con la puntata più bassa.
    
    */

    string[10] targets = ["Target1", "Target2", "Target3","Target4",
                        "Target5","Target6","Target7","Target8", 
                        "Target9","Target10"];
    
    uint[10] targetPositions = [55, 12, 28, 86, 39, 99, 4, 65, 30, 8];
    uint[10] userPositions = [57, 89, 23, 68, 5, 94, 17, 36, 46, 73];

    mapping(string => address) assignedTarget;
    
    address payable owner;
    string  object;
    uint    price;
    uint endAt;
    uint i = 0;
    address winner;
    uint256 best_price;
    bool    is_open;
    address[] users;

    event AuctionOpened(address _owner, string _object, uint256 _initialPrice);
    event AuctionClosed(address _owner, address _winner, uint256 _winningBid);
    event NewBid(string _text, address _bidder, uint256 _bidAmount);
    event FundsWithdrawn(address _withdrawer, uint256 amount);
    event WinningWithdrawn(address _winner, string _object);

    constructor(){
        owner = payable(msg.sender);
    }

    modifier isOwner{
        require(msg.sender == owner, "Only the owner can made this action");
        _;
    }

    modifier isOpened{
        require(is_open == true, "The auction have to opened first");
        _;
    }
    

    function open() public isOwner {
        emit AuctionOpened(owner, object, price);
        is_open = true;
        endAt = block.timestamp + 10 seconds;
    } 

    function buildAuction(string memory _obj, uint256 _price) public isOwner {
        object = _obj;
        price = _price;
        winner = address(0);
        best_price = 0;
        is_open = false;
    }

    function startAuction() public isOwner {
        require(i < 10, "Not enough tasks");
        buildAuction(targets[i], targetPositions[i]);
        open();
        i++;
    }


    function close() public isOpened isOwner {
        require(block.timestamp >= endAt, "Auction still not ended");
        emit AuctionClosed(owner, winner, best_price);
        is_open = false;
    }




    /* I've mapped (address => offered_import) in order to refund users who don't win the auction*/
    function makeOffer(uint value) public isOpened {
        require(value < best_price, "The offer made does not exceed the best");
        require(block.timestamp < endAt, "Auction still not ended");

        emit NewBid("New bid is proposed:", msg.sender, value);
        
        best_price = value;
        winner = msg.sender;   
    }
    
    function retireWin() public {
        require(msg.sender == winner, "Only the winner can obtain the task");
        require(is_open == false, "The auction is still opened");
        emit WinningWithdrawn(winner, object);
        
        assignedTarget[targets[i]] = winner;
    }
}