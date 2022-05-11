//
//  NetworkRequestManager.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/10/22.
//

import Foundation

struct NetworkRequestManager {
    typealias CompleteionBlock = (_ data:NSDictionary)->Void;
    func postRequest(body: String, completionHandler: @escaping CompleteionBlock) {
        let urlPath: String = "https://api.cybertino.io/connect/"
        let url: URL = URL(string: urlPath)!
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        let data = body.data(using: .utf8)
        request.timeoutInterval = 60
        request.httpBody = data
        request.httpShouldHandleCookies=false
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    print("ASynchronous\(jsonResult)")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

struct OperationData: Codable {
    var operationName: String
    var query: String
    var variables: Variables
}

struct OperationInputData: Codable {
    var operationName: String
    var query: String
    var variables: Input
}

enum NetworkType: String, CaseIterable, Codable {
    case eth = "ETH"
    case sol = "SOL"
}

struct Variables: Codable {
    var fromAddr: String?
    var toAddr: String?
    var namespace: String?
    var address: String?
    var first: UInt?
    var alias: String?
    var signature: String?
    var operation: Operation?
    var signingKey: String?
    var network: NetworkType?
    var message: String?
}

struct Input: Codable {
    var input: Variables
}

struct Operation: Codable {
    var name: String
    var from: String
    var to: String
    var namespace: String
    var network: String
    var alias: String
    var timestamp: String
}
