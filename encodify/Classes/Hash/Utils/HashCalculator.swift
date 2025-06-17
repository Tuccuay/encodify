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

struct HashResult: Sendable {
    let algorithm: String
    let hash: String
}

struct HashProgressUpdate: Sendable {
    let progress: Double
    let currentAlgorithm: String
}

class HashCalculator {
    
    // MARK: - Performance Configuration
    
    /// 大文件分块大小 (1MB)
    private static let chunkSize = 1024 * 1024
    /// 大文件阈值 (20MB) - 降低阈值，确保中等文件也能稳定处理
    private static let largeFileThreshold = 20 * 1024 * 1024
    /// 最大并发任务数 (保留一些CPU核心给系统)
    private static let maxConcurrentTasks: Int = {
        let availableProcessors = ProcessInfo.processInfo.activeProcessorCount
        return max(2, min(availableProcessors - 1, 8)) // 最少2个，最多8个并发
    }()
    
    // 按照计算速度分组的算法列表
    private static let fastAlgorithms = ["MD5", "SHA1", "CRC-32", "CRC-16", "Adler-32"]
    private static let mediumAlgorithms = ["SHA224", "SHA256", "MD2", "MD4", "CRC-32C"]
    private static let slowAlgorithms = ["SHA384", "SHA512", "SHA3-224", "SHA3-256", "SHA3-384", "SHA3-512", 
                                       "Keccak-224", "Keccak-256", "Keccak-384", "Keccak-512"]
    
    // 全局取消标志 - 使用 actor 来保证并发安全
    private static let cancellationToken = CancellationToken()
    
    // MARK: - Cancellation Support
    
    actor CancellationToken {
        private var _isCancelled = false
        
        var isCancelled: Bool {
            _isCancelled
        }
        
        func cancel() {
            _isCancelled = true
        }
        
        func reset() {
            _isCancelled = false
        }
    }
    
    static func cancelCalculation() {
        Task {
            await cancellationToken.cancel()
        }
    }
    
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
    
    // MARK: - Large File Support
    
    /// 流式哈希上下文协议
    private protocol StreamingHashContext {
        func update(data: Data)
        func finalize() -> String
    }
    
    /// 流式 MD5 上下文
    private class StreamingMD5Context: StreamingHashContext {
        private var context = CC_MD5_CTX()
        
        init() {
            CC_MD5_Init(&context)
        }
        
        func update(data: Data) {
            data.withUnsafeBytes { bytes in
                CC_MD5_Update(&context, bytes.baseAddress, CC_LONG(data.count))
            }
        }
        
        func finalize() -> String {
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5_Final(&digest, &context)
            return digest.map { String(format: "%02x", $0) }.joined()
        }
    }
    
    /// 流式 SHA1 上下文
    private class StreamingSHA1Context: StreamingHashContext {
        private var context = CC_SHA1_CTX()
        
        init() {
            CC_SHA1_Init(&context)
        }
        
        func update(data: Data) {
            data.withUnsafeBytes { bytes in
                CC_SHA1_Update(&context, bytes.baseAddress, CC_LONG(data.count))
            }
        }
        
        func finalize() -> String {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1_Final(&digest, &context)
            return digest.map { String(format: "%02x", $0) }.joined()
        }
    }
    
    /// 流式 SHA256 上下文
    private class StreamingSHA256Context: StreamingHashContext {
        private var context = CC_SHA256_CTX()
        
        init() {
            CC_SHA256_Init(&context)
        }
        
        func update(data: Data) {
            data.withUnsafeBytes { bytes in
                CC_SHA256_Update(&context, bytes.baseAddress, CC_LONG(data.count))
            }
        }
        
        func finalize() -> String {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256_Final(&digest, &context)
            return digest.map { String(format: "%02x", $0) }.joined()
        }
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
    
    // MARK: - Async Hash Calculation
    
    static func calculateHashesAsync(for input: String) async -> [HashResult] {
        guard let data = input.data(using: .utf8) else { return [] }
        return await calculateHashesAsync(for: data)
    }
    
    static func calculateHashesAsync(for data: Data) async -> [HashResult] {
        return await Task.detached(priority: .userInitiated) {
            return calculateHashes(for: data)
        }.value
    }
    
    // MARK: - Progressive Hash Calculation with Parallel Processing
    
    static func calculateHashesWithProgress(for data: Data) -> AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error> {
        // 重置取消标志
        Task {
            await cancellationToken.reset()
        }
        
        // 根据文件大小选择计算策略
        if data.count > largeFileThreshold {
            return calculateHashesForLargeFile(data: data)
        } else {
            return calculateHashesWithParallelProcessing(for: data)
        }
    }
    
    /// 并行计算哈希算法（适用于小文件）- 按速度优先级处理
    private static func calculateHashesWithParallelProcessing(for data: Data) -> AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error> {
        AsyncThrowingStream { continuation in
            Task.detached(priority: .userInitiated) {
                do {
                    var results: [HashResult] = []
                    let algorithmGroups = [fastAlgorithms, mediumAlgorithms, slowAlgorithms]
                    let totalAlgorithms = fastAlgorithms.count + mediumAlgorithms.count + slowAlgorithms.count
                    var completedCount = 0
                    
                    // 创建 Sendable 的数据副本以避免并发警告
                    let inputData = data
                    
                    // 按优先级分组处理算法
                    for (groupIndex, algorithms) in algorithmGroups.enumerated() {
                        // 检查取消状态
                        if await cancellationToken.isCancelled {
                            continuation.finish(throwing: CancellationError())
                            return
                        }
                        
                        // 使用TaskGroup并行计算当前组的哈希算法
                        await withTaskGroup(of: HashResult?.self) { group in
                            for algorithm in algorithms {
                                group.addTask(priority: .userInitiated) { @Sendable in
                                    // 检查取消状态
                                    if await cancellationToken.isCancelled {
                                        return nil
                                    }
                                    
                                    let hash: String
                                    switch algorithm {
                                    case "MD2":
                                        hash = md2(data: inputData)
                                    case "MD4":
                                        hash = md4(data: inputData)
                                    case "MD5":
                                        hash = inputData.md5().toHexString()
                                    case "SHA1":
                                        hash = inputData.sha1().toHexString()
                                    case "SHA224":
                                        hash = inputData.sha224().toHexString()
                                    case "SHA256":
                                        hash = inputData.sha256().toHexString()
                                    case "SHA384":
                                        hash = inputData.sha384().toHexString()
                                    case "SHA512":
                                        hash = inputData.sha512().toHexString()
                                    case "SHA3-224":
                                        hash = inputData.sha3(.sha224).toHexString()
                                    case "SHA3-256":
                                        hash = inputData.sha3(.sha256).toHexString()
                                    case "SHA3-384":
                                        hash = inputData.sha3(.sha384).toHexString()
                                    case "SHA3-512":
                                        hash = inputData.sha3(.sha512).toHexString()
                                    case "Keccak-224":
                                        hash = inputData.sha3(.keccak224).toHexString()
                                    case "Keccak-256":
                                        hash = inputData.sha3(.keccak256).toHexString()
                                    case "Keccak-384":
                                        hash = inputData.sha3(.keccak384).toHexString()
                                    case "Keccak-512":
                                        hash = inputData.sha3(.keccak512).toHexString()
                                    case "CRC-16":
                                        hash = inputData.crc16().toHexString()
                                    case "CRC-32":
                                        hash = inputData.crc32().toHexString()
                                    case "CRC-32C":
                                        hash = inputData.crc32c().toHexString()
                                    case "Adler-32":
                                        hash = adler32(data: inputData)
                                    default:
                                        return nil
                                    }
                                    return HashResult(algorithm: algorithm, hash: hash)
                                }
                            }
                            
                            // 收集当前组的结果并实时报告进度
                            for await result in group {
                                if let result = result {
                                    results.append(result)
                                    completedCount += 1
                                    
                                    let progress = Double(completedCount) / Double(totalAlgorithms)
                                    continuation.yield((
                                        HashProgressUpdate(progress: progress, currentAlgorithm: result.algorithm),
                                        results
                                    ))
                                }
                            }
                        }
                        
                        // 组间小延迟，给UI更新时间
                        if groupIndex < algorithmGroups.count - 1 {
                            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
                        }
                    }
                    
                    // 完成时发送最终结果
                    continuation.yield((
                        HashProgressUpdate(progress: 1.0, currentAlgorithm: "Complete"),
                        results
                    ))
                    continuation.finish(throwing: nil)
                    
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// 大文件分块处理（流式计算）- 按速度优先级处理
    private static func calculateHashesForLargeFile(data: Data) -> AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error> {
        AsyncThrowingStream { continuation in
            Task.detached(priority: .userInitiated) {
                do {
                    let algorithmGroups = [fastAlgorithms, mediumAlgorithms, slowAlgorithms]
                    let totalAlgorithms = fastAlgorithms.count + mediumAlgorithms.count + slowAlgorithms.count
                    var completedResults: [HashResult] = []
                    
                    // 创建 Sendable 的数据副本以避免并发警告
                    let inputData = data
                    
                    // 根据文件大小动态调整策略
                    let fileSizeMB = Double(inputData.count) / (1024 * 1024)
                    
                    // 按优先级分组顺序处理
                    for algorithms in algorithmGroups {
                        // 检查取消状态
                        if await cancellationToken.isCancelled {
                            continuation.finish(throwing: CancellationError())
                            return
                        }
                        
                        let concurrencyLimit: Int
                        let batchDelay: UInt64
                        
                        if fileSizeMB <= 100 { // 100MB以下
                            concurrencyLimit = min(4, maxConcurrentTasks) // 中等并发
                            batchDelay = 50_000_000 // 50ms
                        } else if fileSizeMB <= 200 { // 200MB以下  
                            concurrencyLimit = min(3, maxConcurrentTasks) // 适中并发
                            batchDelay = 100_000_000 // 100ms
                        } else { // 超大文件
                            concurrencyLimit = min(2, maxConcurrentTasks) // 保守并发
                            batchDelay = 200_000_000 // 200ms
                        }
                        
                        for i in stride(from: 0, to: algorithms.count, by: concurrencyLimit) {
                            // 检查取消状态
                            if await cancellationToken.isCancelled {
                                continuation.finish(throwing: CancellationError())
                                return
                            }
                            
                            let batch = Array(algorithms[i..<min(i + concurrencyLimit, algorithms.count)])
                            
                            // 小批量并行处理
                            await withTaskGroup(of: HashResult?.self) { group in
                                for algorithm in batch {
                                    group.addTask(priority: .userInitiated) { @Sendable in
                                        // 检查取消状态
                                        if await cancellationToken.isCancelled {
                                            return nil
                                        }
                                        
                                        do {
                                            let hash: String
                                            switch algorithm {
                                            case "MD2":
                                                hash = md2(data: inputData)
                                            case "MD4":
                                                hash = md4(data: inputData)
                                            case "MD5":
                                                hash = inputData.md5().toHexString()
                                            case "SHA1":
                                                hash = inputData.sha1().toHexString()
                                            case "SHA224":
                                                hash = inputData.sha224().toHexString()
                                            case "SHA256":
                                                hash = inputData.sha256().toHexString()
                                            case "SHA384":
                                                hash = inputData.sha384().toHexString()
                                            case "SHA512":
                                                hash = inputData.sha512().toHexString()
                                            case "SHA3-224":
                                                hash = inputData.sha3(.sha224).toHexString()
                                            case "SHA3-256":
                                                hash = inputData.sha3(.sha256).toHexString()
                                            case "SHA3-384":
                                                hash = inputData.sha3(.sha384).toHexString()
                                            case "SHA3-512":
                                                hash = inputData.sha3(.sha512).toHexString()
                                            case "Keccak-224":
                                                hash = inputData.sha3(.keccak224).toHexString()
                                            case "Keccak-256":
                                                hash = inputData.sha3(.keccak256).toHexString()
                                            case "Keccak-384":
                                                hash = inputData.sha3(.keccak384).toHexString()
                                            case "Keccak-512":
                                                hash = inputData.sha3(.keccak512).toHexString()
                                            case "CRC-16":
                                                hash = inputData.crc16().toHexString()
                                            case "CRC-32":
                                                hash = inputData.crc32().toHexString()
                                            case "CRC-32C":
                                                hash = inputData.crc32c().toHexString()
                                            case "Adler-32":
                                                hash = adler32(data: inputData)
                                            default:
                                                return nil
                                            }
                                            return HashResult(algorithm: algorithm, hash: hash)
                                        } catch {
                                            // 如果某个算法失败，记录错误但继续处理其他算法
                                            print("Hash calculation failed for \(algorithm): \(error)")
                                            return nil
                                        }
                                    }
                                }
                                
                                for await result in group {
                                    if let result = result {
                                        completedResults.append(result)
                                        
                                        let progress = Double(completedResults.count) / Double(totalAlgorithms)
                                        await MainActor.run {
                                            continuation.yield((
                                                HashProgressUpdate(progress: progress, currentAlgorithm: result.algorithm),
                                                completedResults
                                            ))
                                        }
                                    }
                                }
                            }
                            
                            // 动态延迟，根据文件大小调整
                            try await Task.sleep(nanoseconds: batchDelay)
                            
                            // 只在大文件时进行内存清理
                            if fileSizeMB > 100 {
                                autoreleasepool {
                                    // 强制内存回收
                                }
                            }
                        }
                    }
                    
                    // 完成时发送最终结果
                    await MainActor.run {
                        continuation.yield((
                            HashProgressUpdate(progress: 1.0, currentAlgorithm: "Complete"),
                            completedResults
                        ))
                        continuation.finish(throwing: nil)
                    }
                    
                } catch {
                    await MainActor.run {
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
    }
}
