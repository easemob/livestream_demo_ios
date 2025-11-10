//
//  Crypto.swift
//  EaseMobLiveDemo
//
//  Created by li xiaoming on 6/16/25.
//  Copyright © 2025 zmw. All rights reserved.
//

import Foundation
import CryptoKit

@objc class Crypto: NSObject {
    @objc static func encryto(plainText: String,encryptKey: String) -> String {
        let data = Data(plainText.utf8)
        do {
            let keyData = Data(base64Encoded: encryptKey)!
            let key = SymmetricKey(data: keyData)
            let sealedBox = try AES.GCM.seal(data, using: key)
            if let data = sealedBox.combined {
                // 将加密后的数据转换为Base64字符串
                return data.base64EncodedString()
            } else {
                return ""
            }
        } catch {
            return ""
        }
    }
}
