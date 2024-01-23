// Dichiarazione del contratto Aste
pragma solidity ^0.8.0;

contract Aste {
    address public proprietario;
    string public oggettoAsta;
    uint256 public prezzoIniziale;
    address public offerenteVincitore;
    uint256 public prezzoOffertaVincitrice;
    bool public astaChiusa;

    constructor(string memory _oggettoAsta, uint256 _prezzoIniziale) {
        proprietario = msg.sender;
        oggettoAsta = _oggettoAsta;
        prezzoIniziale = _prezzoIniziale;
        offerenteVincitore = address(0); // Inizialmente nessun vincitore
        prezzoOffertaVincitrice = 0; // Inizialmente nessuna offerta vincente
        astaChiusa = false;
    }

    modifier soloProprietario() {
        require(msg.sender == proprietario, "Solo il proprietario può eseguire questa azione");
        _;
    }

    modifier astaAperta() {
        require(!astaChiusa, "L'asta è chiusa");
        _;
    }

    function faiOfferta() public payable astaAperta {
        require(msg.value > prezzoOffertaVincitrice, "L'offerta non supera l'offerta attuale");
        if (offerenteVincitore != address(0)) {
            // Restituisci i fondi all'offerente precedente
            payable(offerenteVincitore).transfer(prezzoOffertaVincitrice);
        }
        offerenteVincitore = msg.sender;
        prezzoOffertaVincitrice = msg.value;
    }

    function chiudiAsta() public soloProprietario astaAperta {
        astaChiusa = true;
    }

    function ritiraVincita() public {
        require(msg.sender == offerenteVincitore, "Solo l'offerente vincitore può ritirare la vincita");
        require(astaChiusa, "L'asta non è ancora chiusa");
        payable(msg.sender).transfer(prezzoOffertaVincitrice);
    }

    // Funzione per restituire i fondi in caso di asta non vincente
    function ritiraFondi() public {
        require(msg.sender != offerenteVincitore, "L'offerente vincitore non può ritirare i fondi");
        require(astaChiusa, "L'asta non è ancora chiusa");
        payable(msg.sender).transfer(msg.value);
    }
}
