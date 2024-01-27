// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.9;

import "./english_auction.sol";

contract SSI {
    /*
        Ciascun utente punta ad un compito non assegnato quindi map(string => address):
        se l'indirizzo è valido allora il compito è assegnato altrimenti si accettano
        le puntate dagli utenti.
        
        Ogni utente punta il più piccolo incremento in termini di distanza che avrebbe
        vincendo il task (considerando i task già presi).
        
        Vince quello con la puntata più bassa.
    
    */



    uint nUsers;

    string[10] targets = ["Target1", "Target2", "Target3","Target4",
                        "Target5","Target6","Target7","Target8", 
                        "Target9","Target10"];
    
    Auction.Positions[10] userPositions;
    Auction.Positions[10] targetPositions;

    mapping(string => address) assignedTarget;
    
    constructor(uint _nUsers){
        
        nUsers = _nUsers;

        for (uint i = 0; i < nUsers; i++) {

            // Inizializza casualmente le posizioni degli utenti
            userPositions[i].x = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, i))) % 100;
            userPositions[i].y = uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, i))) % 100;

            // Inizializza casualmente le posizioni dei target
            targetPositions[i].x = uint(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), i))) % 100;
            targetPositions[i].y = uint(keccak256(abi.encodePacked(block.prevrandao, msg.sender, i))) % 100;
        
        }

    }

    function SSIAuction() public {

        for(uint i = 0;  i < nUsers; i++){
            Auction auct = new Auction(targets[i], 100, targetPositions[i]);
            
            auct.open();

            while(auct.getUserLenght() != 9){

            }
            
            auct.close();

        }
    }

}