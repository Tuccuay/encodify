//
//  HashGroup.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation

struct HashGroup {
    let title: String
    let subtitle: String
    let algorithms: [HashAlgorithm]
}

struct HashAlgorithm {
    let name: String
    let description: String
    let algorithmKey: String  // 用于匹配 HashResult.algorithm
    let isSecure: Bool
    
    static let allAlgorithms: [HashGroup] = [
        HashGroup(
            title: "Traditional MD Series",
            subtitle: "Legacy message digest algorithms",
            algorithms: [
                HashAlgorithm(
                    name: "MD2",
                    description: "128-bit Message Digest 2 - Early hash algorithm",
                    algorithmKey: "MD2",
                    isSecure: false
                ),
                HashAlgorithm(
                    name: "MD4",
                    description: "128-bit Message Digest 4 - MD5 predecessor",
                    algorithmKey: "MD4",
                    isSecure: false
                ),
                HashAlgorithm(
                    name: "MD5",
                    description: "128-bit Message Digest 5 - Legacy use only",
                    algorithmKey: "MD5",
                    isSecure: false
                )
            ]
        ),
        HashGroup(
            title: "SHA-1 Series",
            subtitle: "Legacy secure hash (160-bit)",
            algorithms: [
                HashAlgorithm(
                    name: "SHA-1",
                    description: "160-bit Secure Hash Algorithm 1 - Deprecated for security",
                    algorithmKey: "SHA1",
                    isSecure: false
                )
            ]
        ),
        HashGroup(
            title: "SHA-2 Family",
            subtitle: "Modern secure hash algorithms",
            algorithms: [
                HashAlgorithm(
                    name: "SHA-224",
                    description: "224-bit SHA-2 hash",
                    algorithmKey: "SHA224",
                    isSecure: true
                ),
                HashAlgorithm(
                    name: "SHA-256",
                    description: "256-bit SHA-2 hash (most common)",
                    algorithmKey: "SHA256",
                    isSecure: true
                ),
                HashAlgorithm(
                    name: "SHA-384",
                    description: "384-bit SHA-2 hash",
                    algorithmKey: "SHA384",
                    isSecure: true
                ),
                HashAlgorithm(
                    name: "SHA-512",
                    description: "512-bit SHA-2 hash (highest security)",
                    algorithmKey: "SHA512",
                    isSecure: true
                )
            ]
        ),
        HashGroup(
            title: "SHA-3 Family",
            subtitle: "NIST standard next-generation hash",
            algorithms: [
                HashAlgorithm(
                    name: "SHA3-224",
                    description: "224-bit SHA-3 hash based on Keccak",
                    algorithmKey: "SHA3-224",
                    isSecure: true
                ),
                HashAlgorithm(
                    name: "SHA3-256",
                    description: "256-bit SHA-3 hash - Modern standard",
                    algorithmKey: "SHA3-256",
                    isSecure: true
                ),
                HashAlgorithm(
                    name: "SHA3-384",
                    description: "384-bit SHA-3 hash",
                    algorithmKey: "SHA3-384",
                    isSecure: true
                ),
                HashAlgorithm(
                    name: "SHA3-512",
                    description: "512-bit SHA-3 hash - Highest security",
                    algorithmKey: "SHA3-512",
                    isSecure: true
                )
            ]
        ),
        HashGroup(
            title: "Keccak Series",
            subtitle: "Original Keccak algorithm (Ethereum uses Keccak-256)",
            algorithms: [
                HashAlgorithm(
                    name: "Keccak-224",
                    description: "224-bit Keccak hash",
                    algorithmKey: "Keccak-224",
                    isSecure: true
                ),
                HashAlgorithm(
                    name: "Keccak-256",
                    description: "256-bit Keccak hash (Used by Ethereum)",
                    algorithmKey: "Keccak-256",
                    isSecure: true
                ),
                HashAlgorithm(
                    name: "Keccak-384",
                    description: "384-bit Keccak hash",
                    algorithmKey: "Keccak-384",
                    isSecure: true
                ),
                HashAlgorithm(
                    name: "Keccak-512",
                    description: "512-bit Keccak hash",
                    algorithmKey: "Keccak-512",
                    isSecure: true
                )
            ]
        ),
        HashGroup(
            title: "CRC & Checksums",
            subtitle: "Data integrity verification algorithms",
            algorithms: [
                HashAlgorithm(
                    name: "CRC-16",
                    description: "16-bit Cyclic Redundancy Check",
                    algorithmKey: "CRC-16",
                    isSecure: false
                ),
                HashAlgorithm(
                    name: "CRC-32",
                    description: "32-bit CRC (ZIP, PNG formats)",
                    algorithmKey: "CRC-32",
                    isSecure: false
                ),
                HashAlgorithm(
                    name: "CRC-32C",
                    description: "32-bit Castagnoli CRC (High performance)",
                    algorithmKey: "CRC-32C",
                    isSecure: false
                ),
                HashAlgorithm(
                    name: "Adler-32",
                    description: "32-bit Adler checksum (zlib compression)",
                    algorithmKey: "Adler-32",
                    isSecure: false
                )
            ]
        )
    ]
}
