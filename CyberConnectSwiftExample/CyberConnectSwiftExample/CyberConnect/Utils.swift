//
//  Utils.swift
//  CyberConnectSwiftExample
//
//  Created by 吴鹏发 on 5/3/22.
//

import Foundation
func onMainThread(_ closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async {
            closure()
        }
    }
}
