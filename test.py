from web3 import Web3

# Connetti a un nodo Ethereum (ad esempio, Infura)
w3 = Web3(Web3.HTTPProvider('http://172.29.58.184:7545'))
print(w3.is_connected())
# Verifica la connessione
if w3.is_connected():
    print("Connesso alla blockchain Ethereum.")