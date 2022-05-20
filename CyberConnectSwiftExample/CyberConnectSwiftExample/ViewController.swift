//
//  ViewController.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/3/22.
//

import UIKit
import WalletConnectSwift
import CryptoKit
import CyberConnect

class ViewController: UIViewController {
    var walletConnect: WalletConnect!
    var cyberConnectInstance: CyberConnect?
    
    @IBOutlet weak var walletAddress: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        walletConnect = WalletConnect(delegate: self)
        walletConnect.reconnectIfNeeded()
    }
    
    @IBAction func authrizeButtonClicked(_ sender: Any) {
        let connectionUrl = walletConnect.connect()
        let deepLinkUrl = "wc://wc?uri=\(connectionUrl)"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let url = URL(string: deepLinkUrl), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func signButtonClicked(_ sender: Any) {
        guard let walletInfo = walletConnect.session.walletInfo else {
            needToConnectWalletFirst()
            return
        }
        let address = walletInfo.accounts[0]
        print(address)
        
        guard let privateKey = cyberConnectInstance?.retriveCyberConnectSignKey(address: address) else {
            print("generate local key fail")
            return
        }
        
        guard let publicKeyString: String = privateKey.publicKey.pemRepresentation.pemRepresentationContent() else {
            print("invalid pem key string")
            return
        }
        
        guard let authMessage: String = cyberConnectInstance?.getAuthorizeString(localPublicKeyPem: publicKeyString) else {
            return
        }
        
        do {
            try walletConnect.client.personal_sign(url: walletConnect.session.url, message: authMessage, account: address) {
                [weak self] response in
                self?.handleReponse(response, expecting: "Signature")
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func getIdentity(_ sender: Any) {
        //you can get your wallet address by using this method, or you can save it in user defaults if you are using your own wallet
        guard let walletInfo = walletConnect.session.walletInfo else {
            needToConnectWalletFirst()
            return
        }
        let address = walletInfo.accounts[0]
        cyberConnectInstance = CyberConnect(address: address)
        cyberConnectInstance?.getIdentity() { data in
            print(data)
        }
    }
    
    @IBAction func connectButtonClicked(_ sender: Any) {
        guard let walletInfo = walletConnect.session.walletInfo else {
            needToConnectWalletFirst()
            return
        }
        let address = walletInfo.accounts[0]
        cyberConnectInstance = CyberConnect(address: address)
        cyberConnectInstance?.connect(toAddress: "0xdb7685f8bce990f5c21720b803a7bdc5b94360d2", alias: "", network: .eth) { data in
            print(data)
        }
    }
    
    @IBAction func setAliasButtonClicked(_ sender: Any) {
        guard let walletInfo = walletConnect.session.walletInfo else {
            needToConnectWalletFirst()
            return
        }
        let address = walletInfo.accounts[0]
        cyberConnectInstance = CyberConnect(address: address)
        cyberConnectInstance?.alias(toAddress: "0xdb7685f8bce990f5c21720b803a7bdc5b94360d2", alias: "What's happening????", network: .eth) { data in
            print(data)
        }
    }
    
    @IBAction func disConnectButtonClicked(_ sender: Any) {
        guard let walletInfo = walletConnect.session.walletInfo else {
            needToConnectWalletFirst()
            return
        }
        let address = walletInfo.accounts[0]
        cyberConnectInstance = CyberConnect(address: address)
        cyberConnectInstance?.disconnect(toAddress: "0xab7824a05ef372c95b9cfeb4a8be487a0d5d8ecb", alias: "", network: .eth) { data in
            print(data)
        }
    }
    
    private func handleReponse(_ response: Response, expecting: String) {
        DispatchQueue.main.async {
            if let error = response.error {
                self.show(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert))
                return
            }
            do {
                let result = try response.result(as: String.self)
                let address = self.walletConnect.session.walletInfo!.accounts[0]
                self.cyberConnectInstance?.registerKey(signature: result, network: .eth) { data in
                    print(data)
                }
                self.show(UIAlertController(title: expecting, message: result, preferredStyle: .alert))
            } catch {
                self.show(UIAlertController(title: "Error",
                                       message: "Unexpected response type error: \(error)",
                                       preferredStyle: .alert))
            }
        }
    }
    
    private func show(_ alert: UIAlertController) {
        onMainThread {
            alert.addAction(UIAlertAction(title: "Close", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    
    private func needToConnectWalletFirst() {
        show(UIAlertController(title: "Wallet address is empty", message: "you may need to get wallet address by click the Get Wallet Address button, you may also need to have metamask or some other wallet the WalletConnect supported on your device", preferredStyle: .alert))
    }
    
    private func needToAuthorizeCyberConnect() {
        show(UIAlertController(title: "Need your wallet to authorize Cyber Connect protocol", message: "Click Sign button and then open your wallet, you can see the authorize message in you wallet, if you can't see the alert in your wallet(this step may need more than one time try)", preferredStyle: .alert))
    }
}

extension ViewController: WalletConnectDelegate {
    func failedToConnect() {
        onMainThread { [unowned self] in
            UIAlertController.showFailedToConnect(from: self)
        }
    }

    func didConnect() {
        guard let walletInfo = walletConnect.session.walletInfo else {
            needToConnectWalletFirst()
            return
        }
        let address = walletInfo.accounts[0]
        onMainThread {
            self.walletAddress.text = "Address: \(address)"
        }
        
        cyberConnectInstance = CyberConnect(address: address)
    }

    func didDisconnect() {
        onMainThread { [unowned self] in
            if let presented = self.presentedViewController {
                presented.dismiss(animated: false)
            }
            UIAlertController.showDisconnected(from: self)
        }
    }
}

extension UIAlertController {
    func withCloseButton() -> UIAlertController {
        addAction(UIAlertAction(title: "Close", style: .cancel))
        return self
    }

    static func showFailedToConnect(from controller: UIViewController) {
        let alert = UIAlertController(title: "Failed to connect", message: nil, preferredStyle: .alert)
        controller.present(alert.withCloseButton(), animated: true)
    }

    static func showDisconnected(from controller: UIViewController) {
        let alert = UIAlertController(title: "Did disconnect", message: nil, preferredStyle: .alert)
        controller.present(alert.withCloseButton(), animated: true)
    }
}

