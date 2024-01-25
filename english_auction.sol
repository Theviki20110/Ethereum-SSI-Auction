// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.9;

contract Auction{

    address owner;
    string  object;
    uint    price;
    address winner;
    uint256 best_price;
    bool    is_open;
    mapping(address => uint256) public bidders;


    constructor(string memory _obj, uint256 _price){
        owner = msg.sender;
        object = _obj;
        price = _price;

        /*
            address(0): A valid Ethereum address, but it is often used to represent 
            the absence of a valid address or an uninitialized value.
        */

        winner = address(0);
        best_price = 0;
        is_open = false;
    }

    modifier isOwner() {
        require(owner == msg.sender, "Only the owner open/can close the auction");
        _;
    }

    modifier isOpened{
        require(is_open == true, "The auction have to opened first");
        _;
    }

    event AuctionOpened(address _owner, string _object, uint256 _initialPrice);
    event AuctionClosed(address _owner, address _winner, uint256 _winningBid);
    event NewBid(string _text, address _bidder, uint256 _bidAmount);
    event FundsWithdrawn(address _withdrawer, uint256 amount);
    event WinningWithdrawn(address _winner, string _object);

    function open() public isOwner{
        is_open = true;
        emit AuctionOpened(owner, object, price);
    } 

    function close() public isOwner isOpened{
        is_open = false;
        emit AuctionClosed(owner, winner, best_price);
    }

    /* I've mapped (address => offered_import) in order to refund users who don't win the auction*/
    function offer() public payable isOpened {
        require(msg.value > best_price, "L'offerta fatta non supera la migliore");
        best_price = msg.value;
        winner = msg.sender;
        emit NewBid("New bid is proposed:", msg.sender, msg.value);
        bidders[winner] += msg.value;
    }
    
    
    function retire_win() public payable {
        require(msg.sender == winner, "Solo il vincitore dell'asta puo' ritirare la vincita");
        require(is_open == false, "L'asta non e' ancora chiusa");
        emit WinningWithdrawn(winner, object);
    }

    /* Function return offered funds at each owner */
    function retire_funds() public payable {
        require(msg.sender != winner, "Il vincitore dell'asta non puo' ritirare i fondi");
        require(is_open == false, "L'asta non e' ancora chiusa");

        emit FundsWithdrawn(msg.sender, bidders[msg.sender]);
        payable(msg.sender).transfer(bidders[msg.sender]);
        
        bidders[msg.sender] = 0;
    }

}