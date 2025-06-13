//
//  HashCalculator.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation
import CryptoSwift

struct HashResult {
    let algorithm: String
    let hash: String
}

class HashCalculator {
    
    static func calculateHashes(for input: String) -> [HashResult] {
        guard let data = input.data(using: .utf8) else { return [] }
        
        var results: [HashResult] = []
        
        // MD5
        let md5Hash = data.md5()
        results.append(HashResult(algorithm: "MD5", hash: md5Hash.toHexString()))
        
        // SHA1
        let sha1Hash = data.sha1()
        results.append(HashResult(algorithm: "SHA1", hash: sha1Hash.toHexString()))
        
        // SHA224
        let sha224Hash = data.sha224()
        results.append(HashResult(algorithm: "SHA224", hash: sha224Hash.toHexString()))
        
        // SHA256
        let sha256Hash = data.sha256()
        results.append(HashResult(algorithm: "SHA256", hash: sha256Hash.toHexString()))
        
        // SHA384
        let sha384Hash = data.sha384()
        results.append(HashResult(algorithm: "SHA384", hash: sha384Hash.toHexString()))
        
        // SHA512
        let sha512Hash = data.sha512()
        results.append(HashResult(algorithm: "SHA512", hash: sha512Hash.toHexString()))
        
        return results
    }
}
