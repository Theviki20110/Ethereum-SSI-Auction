// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.9;

contract Auction{

    address owner;
    string  object;
    uint    price;
    address winner;
    uint256 best_price;
    bool    is_open;


    constructor(string memory _obj, uint256 _price){
        owner = msg.sender;
        object = _obj;
        price = _price;

        /*
            address(0): indirizzo Ethereum valido, ma è spesso utilizzato 
            per rappresentare l'assenza di un indirizzo valido o un valore 
            non inizializzato
        */

        winner = address(0);
        best_price = 0;
        is_open = false;
    }


    /* Lo uso per verificare che l'account in uso sia il proprietario dell'asta o meno */
    modifier isOwner() {
        require(owner == msg.sender, "Only the owner open/can close the auction");
        _;
    }

    modifier isOpened{
        require(is_open == true, "The auction have to opened first");
        _;
    }


    function open() public isOwner{
        is_open = true;
    }

    function close() public isOwner isOpened{
        is_open = false;
    }

    function offer() public payable isOpened {
        require(msg.value > best_price, "L'offerta fatta non supera la migliore");
        best_price = msg.value;
        winner = msg.sender;
    }

    function retire_win() public payable {
        require(msg.sender == winner, "Solo il vincitore dell'asta puo' ritirare la vincita");
        require(is_open == false, "L'asta non e' ancora chiusa");
        payable(msg.sender).transfer(msg.value);
    }

    function retire_funds() public payable {
        require(msg.sender != winner, "Il vincitore dell'asta non puo' ritirare i fondi");
        require(is_open == false, "L'asta non e' ancora chiusa");
        payable(msg.sender).transfer(msg.value);
    }

}