//
//  CyberConnect.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/3/22.
//

import Foundation
enum ConnectionType: String, CaseIterable {
    case follow = "follow"
    case like = "like"
    case report = "report"
    case watch = "watch"
    case vote = "vote"
}

enum SignResult: String, CaseIterable {
    case invalid = "INVALID_SIGNATURE"
    case success = "SUCCESS"
}

struct CyberConnect {
    var address: String
    func connect(fromAddress: String, toAddress: String, alias: String, network: NetworkType, connectType: ConnectionType, compeletion: @escaping CompleteionBlock) {
        NetworkRequestManager().connect(fromAddress: fromAddress, toAddress: toAddress, alias: alias, network: network, connectType: connectType, compeletion: compeletion)
    }
    
    func disconnect(fromAddress: String, toAddress: String, alias: String, network: NetworkType, compeletion: @escaping CompleteionBlock) {
        NetworkRequestManager().disconnect(fromAddress: fromAddress, toAddress: toAddress, alias: alias, network: network, compeletion: compeletion)
    }
    
    func alias() {
        
    }
    
    func batchConnect() {
        
    }
    
    func getIdentity(address: String, completion: @escaping CompleteionBlock) {
        NetworkRequestManager().getIdentity(address: address, completion: completion)
    }
    
    func registerKey(address: String, signature: String, network: NetworkType, completion: @escaping CompleteionBlock) {
        NetworkRequestManager().registerKey(address: address, signature: signature, network: network, completion: completion)
    }
}
