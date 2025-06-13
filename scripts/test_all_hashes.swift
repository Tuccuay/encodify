#!/usr/bin/env swift

import Foundation

// 模拟 HashResult 结构
struct HashResult {
    let algorithm: String
    let hash: String
}

// 简单测试函数
func testHashAlgorithms() {
    print("🔐 哈希算法测试")
    print("================")
    
    let testInput = "Hello, World!"
    print("输入: \(testInput)")
    print()
    
    // 注意：这个脚本只是演示用途
    // 实际的 HashCalculator 需要在 iOS 项目中运行
    
    print("支持的算法类别:")
    print()
    
    print("📋 传统 MD 系列:")
    print("- MD2 (CommonCrypto)")
    print("- MD4 (CommonCrypto)")  
    print("- MD5 (CryptoSwift)")
    print()
    
    print("🔒 SHA-1 系列:")
    print("- SHA-1")
    print()
    
    print("🛡 SHA-2 系列:")
    print("- SHA-224")
    print("- SHA-256")
    print("- SHA-384") 
    print("- SHA-512")
    print()
    
    print("🆕 SHA-3 系列:")
    print("- SHA3-224")
    print("- SHA3-256")
    print("- SHA3-384")
    print("- SHA3-512")
    print()
    
    print("⚡ Keccak 系列:")
    print("- Keccak-224")
    print("- Keccak-256 (以太坊)")
    print("- Keccak-384")
    print("- Keccak-512")
    print()
    
    print("🔍 校验和系列:")
    print("- CRC-16")
    print("- CRC-32")
    print("- CRC-32C")
    print("- Adler-32")
    print()
    
    print("✅ 总计支持: 20 种哈希和校验算法")
    print()
    print("🎯 推荐使用:")
    print("• 安全应用: SHA-256, SHA3-256")
    print("• 区块链: Keccak-256")
    print("• 数据验证: CRC-32, Adler-32")
    print("• 兼容性: MD5 (仅非安全场景)")
}

testHashAlgorithms()
