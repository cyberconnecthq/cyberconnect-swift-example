# cyberconnect-swift-example
cyberconnect-swift-example is a demo project based on
[cyberconnect-swift](https://github.com/cyberconnecthq/cyberconnect-swift-lib) and [WalletConnect](https://github.com/trustwallet/wallet-connect-swift)

### Here is the process of how cyberconnect work:
#### 1. Get address of your wallet
#### 2. Generate a pair of P256 keys and save it in keychain
#### 3. Sign a **message** with you wallet(should be pair with the address in step 1) and get the _signature_
#### 4. You can get right format message:
```
let cyberconnect = CyberConnect(address: WALLETADDRESS) //in step 1
let message = cyberconnect.getAuthorizeString(localPublicKeyPem: youPublicKeyPem) //key pairs in step 2
```
#### 5. Sign this message with your wallet and get signature
```
let signature = signature //from step 3
cyberconnect.registerKey(signature: signature, network: .eth) { data in
    print(data) 
}
```
#### 6. Now you can use cyberconnect to create your own connection with other people in web3.0 world if you get success feedback in step 5

Here is a demo Video:

https://user-images.githubusercontent.com/10152008/169455548-97e65405-7632-4019-8877-161d81f27f92.MP4

Want to know more APIs CyberConnect supported please refer to: [cyberconnect-swift](https://github.com/cyberconnecthq/cyberconnect-swift-lib)

### About WalletConnect
WalletConnect is a tool to use your wallet function based on universal link or QR code, many mainstream wallets is supported for now.

⚠️ If you have your own wallet,of course you can sign your message with your own wallet, should be easier, and have better user experience. Cause WalletConnect use websocket to check the status of signature, not so stable for now and sometimes you may need to active wallet app back and forth to show the signature prompt(at least for metamask it behave like this, maybe it's a bug of metamask, but it works anyway)

⚠️ when you try to integrate WalletConnect to your project, make sure you implement LSApplicationQueriesSchemes, otherwise you can't active wallets to sign some particular message on your iPhone.



