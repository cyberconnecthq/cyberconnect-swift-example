//
//  ViewController.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/3/22.
//

import UIKit
import WalletConnectSwift

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
        let authMessage = Utils.shared.getAuthorizeString(localPublicKeyPem: "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEjLfORxv/Ndc5Kwax4+3StpZHMCwBKpEe1EptDXxIhQVhV9LyU4rulho/u7DddtW+C7+y6fYe2kaYudmAzBIcbA==")
        do {
            try walletConnect.client.personal_sign(url: walletConnect.session.url, message: authMessage, account: walletConnect.session.walletInfo!.accounts[0]) {
                [weak self] response in
                self?.handleReponse(response, expecting: "Signature")
            }
        } catch {
            print(error)
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
