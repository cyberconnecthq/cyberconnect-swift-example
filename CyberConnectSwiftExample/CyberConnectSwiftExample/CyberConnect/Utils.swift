//
//  Utils.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/3/22.
//

import Foundation
import CryptoKit

struct Utils {
    static let shared = Utils()
    func generateCyberConnectSignKey(address: String) {
        let privateKey = P256.Signing.PrivateKey()
        let key = getKey(address: address)
        do {
            try SecurityKeyStore().storeKey(privateKey, label: key)
        } catch {
            print(error)
        }
    }

    func retriveCyberConnectSignKey(address: String) -> P256.Signing.PrivateKey? {
        let key = getKey(address: address)
        do {
            guard let result: P256.Signing.PrivateKey = try SecurityKeyStore().readKey(label: key) else {
                return nil
            }
            
            return result
        } catch {
            print(error)
        }
        return nil
    }

    func getAuthorizeString(localPublicKeyPem: String) -> String {
        return "I authorize CyberConnect from this device using signing key:\n\(localPublicKeyPem)"
    }
    
    private func getKey(address: String) -> String {
        return "CyberConnectKey_\(address)"
    }
}

func onMainThread(_ closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async {
            closure()
        }
    }
}
