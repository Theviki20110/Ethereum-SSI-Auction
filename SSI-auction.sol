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
    
    uint[10] targetCosts = [55, 12, 28, 86, 39, 99, 4, 65, 30, 8];

    mapping(address => uint[]) userTasks;
    mapping(string => address) assignedTarget;
    
    address payable owner;
    string  object;
    uint    price;
    uint endAt;
    uint i = 0;
    address winner;
    uint256 best_offer;
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
        endAt = block.timestamp + 50 seconds;
    } 

    function buildAuction(string memory _obj, uint256 _price) public isOwner {
        object = _obj;
        price = _price;
        winner = address(0);
        best_offer = 200;
        is_open = false;
    }

    function startAuction() public isOwner {
        require(i < 10, "Not enough tasks");
        require(checkOtherTasks() == true, "All tasks have been already assigned");
        buildAuction(targets[i], targetCosts[i]);
        open();
        i++;
    }

    /* Check if there are still other tasks to be assigned */
    function checkOtherTasks() public view isOwner returns (bool status) { 
        if (i < targets.length){
            return true;
        }
        else{
            return false;
        }
    }


    function close() public isOpened isOwner {
        require(block.timestamp >= endAt, "Auction still not ended");
        emit AuctionClosed(owner, winner, best_offer);
        is_open = false;
    }

    /* I've mapped (address => offered_import) in order to refund users who don't win the auction*/
    function makeOffer(uint value) public isOpened {
        require(msg.sender != owner, "The owner can't make an offer");
        require(block.timestamp < endAt, "Auction closed");
        require(value < best_offer, "The offer made exceed the best");

        emit NewBid("New bid is proposed:", msg.sender, value);
        
        best_offer = value;
        winner = msg.sender;   
    }

    function offer() public isOpened{
        uint totalActualCosts = 0;

        for(uint j = 0; j < userTasks[msg.sender].length; j++){
            totalActualCosts += userTasks[msg.sender][j];
        }

        makeOffer(totalActualCosts + price);
    }

    
    function assignTask() public isOwner{
        require(msg.sender == owner, "Only the owner can assign the task");
        require(is_open == false, "The auction is still opened");
        emit WinningWithdrawn(winner, object);
        
        assignedTarget[targets[i]] = winner;
        userTasks[winner].push(price);
    }
}