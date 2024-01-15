from web3 import Web3

# Connetti a un nodo Ethereum (ad esempio, Infura)
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:7545'))

# Verifica la connessione
if w3.isConnected():
    print("Connesso alla blockchain Ethereum.")