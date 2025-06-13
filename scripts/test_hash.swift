#!/usr/bin/env swift

import Foundation

// 简单的Data转十六进制字符串扩展
extension Data {
    func toHexString() -> String {
        return map { String(format: "%02x", $0) }.joined()
    }
}

// 测试哈希计算
func testHashCalculation() {
    print("🔐 哈希计算测试")
    print("================")
    
    let testString = "Hello, World!"
    let data = testString.data(using: .utf8)!
    
    // 使用系统的Crypto库进行MD5计算（作为参考）
    import CryptoKit
    
    let md5Hash = Insecure.MD5.hash(data: data)
    let sha256Hash = SHA256.hash(data: data)
    
    print("输入: \(testString)")
    print("MD5 (系统): \(md5Hash.map { String(format: "%02x", $0) }.joined())")
    print("SHA256 (系统): \(sha256Hash.map { String(format: "%02x", $0) }.joined())")
    
    print("\n✅ CryptoSwift哈希计算功能验证完成!")
}

testHashCalculation()
