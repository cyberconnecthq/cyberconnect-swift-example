//
//  CyberConnectSwiftExampleTests.swift
//  CyberConnectSwiftExampleTests
//
//  Created by 吴鹏发 on 5/3/22.
//

import XCTest
@testable import CyberConnectSwiftExample
import CryptoKit
import CyberConnect

class CyberConnectSwiftExampleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let address = "dasdsaddasddadsadasdas"
        let cyberConnect = CyberConnect(address: address)
        if let privateKey: P256.Signing.PrivateKey = cyberConnect.retriveCyberConnectSignKey(address: address) {
            print(privateKey.publicKey.pemRepresentation)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
