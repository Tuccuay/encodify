//
//  HashCalculator.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation
import CryptoSwift
import CommonCrypto

struct HashResult {
    let algorithm: String
    let hash: String
}

class HashCalculator {
    
    // MARK: - MD2 和 MD4 实现 (使用 CommonCrypto)
    
    private static func md2(data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD2_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            CC_MD2(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    private static func md4(data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD4_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            CC_MD4(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Adler-32 实现
    
    private static func adler32(data: Data) -> String {
        let MOD_ADLER: UInt32 = 65521
        var a: UInt32 = 1
        var b: UInt32 = 0
        
        for byte in data {
            a = (a + UInt32(byte)) % MOD_ADLER
            b = (b + a) % MOD_ADLER
        }
        
        let result = (b << 16) | a
        return String(format: "%08x", result)
    }
    
    static func calculateHashes(for input: String) -> [HashResult] {
        guard let data = input.data(using: .utf8) else { return [] }
        return calculateHashes(for: data)
    }
    
    static func calculateHashes(for data: Data) -> [HashResult] {
        var results: [HashResult] = []
        
        // MARK: - 传统 MD 系列 (使用 CommonCrypto)
        
        // MD2 (使用 CommonCrypto)
        let md2Hash = md2(data: data)
        results.append(HashResult(algorithm: "MD2", hash: md2Hash))
        
        // MD4 (使用 CommonCrypto)
        let md4Hash = md4(data: data)
        results.append(HashResult(algorithm: "MD4", hash: md4Hash))
        
        // MD5 (使用 CryptoSwift)
        let md5Hash = data.md5()
        results.append(HashResult(algorithm: "MD5", hash: md5Hash.toHexString()))
        
        // MARK: - SHA-1 系列
        
        // SHA1
        let sha1Hash = data.sha1()
        results.append(HashResult(algorithm: "SHA1", hash: sha1Hash.toHexString()))
        
        // MARK: - SHA-2 系列
        
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
        
        // MARK: - SHA-3 系列
        
        // SHA3 系列
        let sha3_224Hash = data.sha3(.sha224)
        results.append(HashResult(algorithm: "SHA3-224", hash: sha3_224Hash.toHexString()))
        
        let sha3_256Hash = data.sha3(.sha256)
        results.append(HashResult(algorithm: "SHA3-256", hash: sha3_256Hash.toHexString()))
        
        let sha3_384Hash = data.sha3(.sha384)
        results.append(HashResult(algorithm: "SHA3-384", hash: sha3_384Hash.toHexString()))
        
        let sha3_512Hash = data.sha3(.sha512)
        results.append(HashResult(algorithm: "SHA3-512", hash: sha3_512Hash.toHexString()))
        
        // MARK: - Keccak 系列
        
        // Keccak 系列
        let keccak224Hash = data.sha3(.keccak224)
        results.append(HashResult(algorithm: "Keccak-224", hash: keccak224Hash.toHexString()))
        
        let keccak256Hash = data.sha3(.keccak256)
        results.append(HashResult(algorithm: "Keccak-256", hash: keccak256Hash.toHexString()))
        
        let keccak384Hash = data.sha3(.keccak384)
        results.append(HashResult(algorithm: "Keccak-384", hash: keccak384Hash.toHexString()))
        
        let keccak512Hash = data.sha3(.keccak512)
        results.append(HashResult(algorithm: "Keccak-512", hash: keccak512Hash.toHexString()))
        
        // MARK: - CRC 校验和系列
        
        // CRC 系列
        let crc16Hash = data.crc16()
        results.append(HashResult(algorithm: "CRC-16", hash: crc16Hash.toHexString()))
        
        let crc32Hash = data.crc32()
        results.append(HashResult(algorithm: "CRC-32", hash: crc32Hash.toHexString()))
        
        let crc32cHash = data.crc32c()
        results.append(HashResult(algorithm: "CRC-32C", hash: crc32cHash.toHexString()))
        
        // Adler-32
        let adler32Hash = adler32(data: data)
        results.append(HashResult(algorithm: "Adler-32", hash: adler32Hash))
        
        return results
    }
}
