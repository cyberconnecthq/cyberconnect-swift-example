//
//  ViewController.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/3/22.
//

import UIKit
import WalletConnectSwift
import CryptoKit

class ViewController: UIViewController {
    var walletConnect: WalletConnect!
    
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
            print("wallet session error")
            return
        }
        let address = walletInfo.accounts[0]
        print(address)
        guard let privateKey = Utils.shared.retriveCyberConnectSignKey(address: address) else {
            print("generate local key fail")
            return
        }
        
        guard let publicKeyString: String = privateKey.publicKey.pemRepresentation.pemRepresentationContent() else {
            print("invalid pem key string")
            return
        }
        
        let authMessage = Utils.shared.getAuthorizeString(localPublicKeyPem: publicKeyString)
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
            print("wallet session error")
            return
        }
        let address = walletInfo.accounts[0]
        CyberConnect.shared.getIdentity(address: address) { data in
            print(data)
        }
    }
    
    @IBAction func connectButtonClicked(_ sender: Any) {
        guard let walletInfo = walletConnect.session.walletInfo else {
            print("wallet session error")
            return
        }
        let address = walletInfo.accounts[0]
        CyberConnect.shared.connect(fromAddress: address, toAddress: "0xab7824a05ef372c95b9cfeb4a8be487a0d5d8ecb", alias: "", network: .eth) { data in
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
                CyberConnect.shared.registerKey(address: address, signature: result, network: .eth) { data in
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
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        self.present(alert, animated: true)
    }
}

extension ViewController: WalletConnectDelegate {
    func failedToConnect() {
        onMainThread { [unowned self] in
            UIAlertController.showFailedToConnect(from: self)
        }
    }

    func didConnect() {
        
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

