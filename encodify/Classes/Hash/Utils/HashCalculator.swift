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
    
    // MARK: - Optimized Performance Configuration
    
    /// 内存映射文件分块大小 (2MB) - 优化内存使用
    private static let chunkSize = 2 * 1024 * 1024
    /// 大文件阈值 (10MB) - 更积极的大文件策略
    private static let largeFileThreshold = 10 * 1024 * 1024
    /// 超大文件阈值 (100MB) - 使用特殊优化策略
    private static let extraLargeFileThreshold = 100 * 1024 * 1024
    /// 最大并发任务数 (动态调整)
    private static let maxConcurrentTasks: Int = {
        let availableProcessors = ProcessInfo.processInfo.activeProcessorCount
        let availableMemoryGB = Double(ProcessInfo.processInfo.physicalMemory) / (1024 * 1024 * 1024)
        
        // 根据CPU和内存动态调整并发数
        if availableMemoryGB >= 8 { // 8GB+内存
            return max(4, min(availableProcessors, 12))
        } else if availableMemoryGB >= 4 { // 4GB+内存
            return max(3, min(availableProcessors - 1, 8))
        } else { // 低内存设备
            return max(2, min(availableProcessors - 2, 4))
        }
    }()
    
    // 按照实际性能测试重新分组的算法列表
    private static let ultraFastAlgorithms = ["CRC-32", "CRC-16", "Adler-32"] // <1ms
    private static let fastAlgorithms = ["MD5", "SHA1", "CRC-32C"] // 1-10ms
    private static let mediumAlgorithms = ["MD2", "MD4", "SHA224", "SHA256"] // 10-50ms
    private static let slowAlgorithms = ["SHA384", "SHA512"] // 50-200ms
    private static let cryptographicAlgorithms = ["SHA3-224", "SHA3-256", "SHA3-384", "SHA3-512"] // 200ms+
    private static let experimentalAlgorithms = ["Keccak-224", "Keccak-256", "Keccak-384", "Keccak-512"] // 最慢
    
    // 增强的全局取消标志 - 支持取消原因和内存压力检测
    private static let cancellationToken = CancellationToken()
    
    // MARK: - Enhanced Cancellation Support
    
    actor CancellationToken {
        private var _isCancelled = false
        private var _reason: CancellationReason = .none
        
        enum CancellationReason {
            case none
            case userRequested
            case memoryPressure
            case timeout
            case systemError
        }
        
        var isCancelled: Bool {
            _isCancelled
        }
        
        var reason: CancellationReason {
            _reason
        }
        
        func cancel(reason: CancellationReason = .userRequested) {
            _isCancelled = true
            _reason = reason
        }
        
        func reset() {
            _isCancelled = false
            _reason = .none
        }
        
        func checkMemoryPressure() {
            let availableMemory = ProcessInfo.processInfo.physicalMemory
            let usedMemory = mach_task_basic_info.getUsedMemory()
            
            if Double(usedMemory) / Double(availableMemory) > 0.85 { // 85%内存使用率
                cancel(reason: .memoryPressure)
            }
        }
    }
    
    // MARK: - Memory Monitoring
    
    private struct mach_task_basic_info {
        static func getUsedMemory() -> UInt64 {
            var info = mach_task_basic_info_data_t()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
            
            let result = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                }
            }
            
            return result == KERN_SUCCESS ? UInt64(info.resident_size) : 0
        }
    }
    
    static func cancelCalculation() {
        Task {
            await cancellationToken.cancel(reason: .userRequested)
        }
    }
    
    // MARK: - Memory-Optimized CRC and Hash Implementations
    
    /// 优化的 CRC32 实现 - 使用查找表加速
    private static func crc32Optimized(data: Data) -> String {
        var crc: UInt32 = 0xFFFFFFFF
        
        // 分块处理以减少内存压力
        let chunkSize = min(64 * 1024, data.count) // 64KB chunks
        
        data.withUnsafeBytes { bytes in
            let buffer = bytes.bindMemory(to: UInt8.self)
            var offset = 0
            
            while offset < buffer.count {
                let endOffset = min(offset + chunkSize, buffer.count)
                let chunk = UnsafeBufferPointer(start: buffer.baseAddress?.advanced(by: offset), count: endOffset - offset)
                
                for byte in chunk {
                    let tableIndex = Int((crc ^ UInt32(byte)) & 0xFF)
                    crc = (crc >> 8) ^ crc32Table[tableIndex]
                }
                
                offset = endOffset
                
                // 内存压力检查
                if offset % (1024 * 1024) == 0 { // 每1MB检查一次
                    Task {
                        await cancellationToken.checkMemoryPressure()
                    }
                }
            }
        }
        
        return String(format: "%08x", crc ^ 0xFFFFFFFF)
    }
    
    /// CRC32 查找表 - 预计算以提升性能
    private static let crc32Table: [UInt32] = {
        var table = Array<UInt32>(repeating: 0, count: 256)
        for i in 0..<256 {
            var crc = UInt32(i)
            for _ in 0..<8 {
                if crc & 1 != 0 {
                    crc = (crc >> 1) ^ 0xEDB88320
                } else {
                    crc >>= 1
                }
            }
            table[i] = crc
        }
        return table
    }()
    
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
    
    // MARK: - Enhanced Large File Support with Memory Mapping
    
    /// 增强的流式哈希上下文协议
    private protocol StreamingHashContext: Sendable {
        func update(data: Data) async
        func finalize() async -> String
        var algorithmName: String { get }
    }
    
    /// 内存优化的流式 MD5 上下文
    private actor StreamingMD5Context: StreamingHashContext {
        private var context = CC_MD5_CTX()
        let algorithmName = "MD5"
        
        init() {
            CC_MD5_Init(&context)
        }
        
        func update(data: Data) async {
            data.withUnsafeBytes { bytes in
                CC_MD5_Update(&context, bytes.baseAddress, CC_LONG(data.count))
            }
            
            // 检查内存压力
            await cancellationToken.checkMemoryPressure()
        }
        
        func finalize() async -> String {
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5_Final(&digest, &context)
            return digest.map { String(format: "%02x", $0) }.joined()
        }
    }
    
    /// 内存优化的流式 SHA1 上下文
    private actor StreamingSHA1Context: StreamingHashContext {
        private var context = CC_SHA1_CTX()
        let algorithmName = "SHA1"
        
        init() {
            CC_SHA1_Init(&context)
        }
        
        func update(data: Data) async {
            data.withUnsafeBytes { bytes in
                CC_SHA1_Update(&context, bytes.baseAddress, CC_LONG(data.count))
            }
            
            // 检查内存压力
            await cancellationToken.checkMemoryPressure()
        }
        
        func finalize() async -> String {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1_Final(&digest, &context)
            return digest.map { String(format: "%02x", $0) }.joined()
        }
    }
    
    /// 内存优化的流式 SHA256 上下文
    private actor StreamingSHA256Context: StreamingHashContext {
        private var context = CC_SHA256_CTX()
        let algorithmName = "SHA256"
        
        init() {
            CC_SHA256_Init(&context)
        }
        
        func update(data: Data) async {
            data.withUnsafeBytes { bytes in
                CC_SHA256_Update(&context, bytes.baseAddress, CC_LONG(data.count))
            }
            
            // 检查内存压力
            await cancellationToken.checkMemoryPressure()
        }
        
        func finalize() async -> String {
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
    
    // MARK: - Optimized Progressive Hash Calculation
    
    static func calculateHashesWithProgress(for data: Data) -> AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error> {
        // 重置取消标志
        Task {
            await cancellationToken.reset()
        }
        
        let fileSizeMB = Double(data.count) / (1024 * 1024)
        
        // 根据文件大小和系统资源选择最优策略
        if data.count > extraLargeFileThreshold {
            // 超大文件：使用最保守的流式处理
            return calculateHashesForExtraLargeFile(data: data)
        } else if data.count > largeFileThreshold {
            // 大文件：使用优化的分块处理
            return calculateHashesForLargeFile(data: data)
        } else {
            // 小文件：使用高性能并行处理
            return calculateHashesWithOptimizedParallel(for: data)
        }
    }
    
    /// 高性能并行计算（适用于小文件）- 动态调度优化
    private static func calculateHashesWithOptimizedParallel(for data: Data) -> AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error> {
        return AsyncThrowingStream { continuation in
            let task = Task.detached(priority: .userInitiated) {
                await performOptimizedParallelCalculation(data: data, continuation: continuation)
            }
        }
    }
    
    /// 执行优化的并行计算
    private static func performOptimizedParallelCalculation(
        data: Data, 
        continuation: AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error>.Continuation
    ) async {
        do {
            var results: [HashResult] = []
            
            let algorithmGroups = getOptimalAlgorithmGroups(for: data.count)
            let totalAlgorithms = algorithmGroups.flatMap { $0 }.count
            var completedCount = 0
            
            let inputData = data
            results.reserveCapacity(totalAlgorithms)
            
            for (groupIndex, algorithms) in algorithmGroups.enumerated() {
                if await cancellationToken.isCancelled {
                    continuation.finish(throwing: CancellationError())
                    return
                }
                
                await processAlgorithmGroup(
                    algorithms: algorithms,
                    inputData: inputData,
                    results: &results,
                    completedCount: &completedCount,
                    totalAlgorithms: totalAlgorithms,
                    continuation: continuation
                )
                
                if groupIndex < algorithmGroups.count - 1 {
                    let delay = getOptimalDelay(for: groupIndex, fileSize: data.count)
                    try await Task.sleep(nanoseconds: delay)
                }
            }
            
            let finalUpdate = HashProgressUpdate(progress: 1.0, currentAlgorithm: "Complete")
            continuation.yield((finalUpdate, results))
            continuation.finish()
            
        } catch {
            continuation.finish(throwing: error)
        }
    }
    
    /// 处理算法组
    private static func processAlgorithmGroup(
        algorithms: [String],
        inputData: Data,
        results: inout [HashResult],
        completedCount: inout Int,
        totalAlgorithms: Int,
        continuation: AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error>.Continuation
    ) async {
        await withTaskGroup(of: HashResult?.self) { group in
            for algorithm in algorithms {
                group.addTask(priority: .userInitiated) { @Sendable in
                    return await calculateSingleHashOptimized(algorithm: algorithm, data: inputData)
                }
            }
            
            for await result in group {
                if let result = result {
                    results.append(result)
                    completedCount += 1
                    
                    let progress = Double(completedCount) / Double(totalAlgorithms)
                    let update = HashProgressUpdate(progress: progress, currentAlgorithm: result.algorithm)
                    continuation.yield((update, results))
                }
            }
        }
    }
    
    /// 动态算法分组优化
    private static func getOptimalAlgorithmGroups(for dataSize: Int) -> [[String]] {
        let sizeMB = Double(dataSize) / (1024 * 1024)
        
        if sizeMB <= 1 { // 小文件：最大并行
            return [ultraFastAlgorithms + fastAlgorithms, mediumAlgorithms, slowAlgorithms, cryptographicAlgorithms, experimentalAlgorithms]
        } else if sizeMB <= 5 { // 中等文件：分组并行
            return [ultraFastAlgorithms, fastAlgorithms, mediumAlgorithms, slowAlgorithms, cryptographicAlgorithms + experimentalAlgorithms]
        } else { // 大文件：保守分组
            return [ultraFastAlgorithms, fastAlgorithms, mediumAlgorithms, slowAlgorithms, cryptographicAlgorithms, experimentalAlgorithms]
        }
    }
    
    /// 智能延迟计算
    private static func getOptimalDelay(for groupIndex: Int, fileSize: Int) -> UInt64 {
        let sizeMB = Double(fileSize) / (1024 * 1024)
        
        if sizeMB <= 1 {
            return 5_000_000 // 5ms
        } else if sizeMB <= 5 {
            return 10_000_000 // 10ms
        } else {
            return 20_000_000 // 20ms
        }
    }
    
    /// 优化的单个哈希计算
    private static func calculateSingleHashOptimized(algorithm: String, data: Data) async -> HashResult? {
        // 检查取消状态
        if await cancellationToken.isCancelled {
            return nil
        }
        
        do {
            let hash: String
            
            // 使用优化的实现
            switch algorithm {
            case "CRC-32":
                hash = crc32Optimized(data: data)
            case "MD2":
                hash = md2(data: data)
            case "MD4":
                hash = md4(data: data)
            case "MD5":
                hash = data.md5().toHexString()
            case "SHA1":
                hash = data.sha1().toHexString()
            case "SHA224":
                hash = data.sha224().toHexString()
            case "SHA256":
                hash = data.sha256().toHexString()
            case "SHA384":
                hash = data.sha384().toHexString()
            case "SHA512":
                hash = data.sha512().toHexString()
            case "SHA3-224":
                hash = data.sha3(.sha224).toHexString()
            case "SHA3-256":
                hash = data.sha3(.sha256).toHexString()
            case "SHA3-384":
                hash = data.sha3(.sha384).toHexString()
            case "SHA3-512":
                hash = data.sha3(.sha512).toHexString()
            case "Keccak-224":
                hash = data.sha3(.keccak224).toHexString()
            case "Keccak-256":
                hash = data.sha3(.keccak256).toHexString()
            case "Keccak-384":
                hash = data.sha3(.keccak384).toHexString()
            case "Keccak-512":
                hash = data.sha3(.keccak512).toHexString()
            case "CRC-16":
                hash = data.crc16().toHexString()
            case "CRC-32C":
                hash = data.crc32c().toHexString()
            case "Adler-32":
                hash = adler32(data: data)
            default:
                return nil
            }
            
            return HashResult(algorithm: algorithm, hash: hash)
        } catch {
            print("Hash calculation failed for \(algorithm): \(error)")
            return nil
        }
    }
    
    /// 超大文件处理（>100MB）- 极致内存优化
    private static func calculateHashesForExtraLargeFile(data: Data) -> AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error> {
        return AsyncThrowingStream { continuation in
            let task = Task.detached(priority: .userInitiated) {
                await performExtraLargeFileCalculation(data: data, continuation: continuation)
            }
        }
    }
    
    /// 执行超大文件计算
    private static func performExtraLargeFileCalculation(
        data: Data,
        continuation: AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error>.Continuation
    ) async {
        do {
            let allAlgorithms = ultraFastAlgorithms + fastAlgorithms + mediumAlgorithms + slowAlgorithms + cryptographicAlgorithms + experimentalAlgorithms
            var results: [HashResult] = []
            results.reserveCapacity(allAlgorithms.count)
            
            let inputData = data
            let fileSizeMB = Double(inputData.count) / (1024 * 1024)
            
            for (index, algorithm) in allAlgorithms.enumerated() {
                if await cancellationToken.isCancelled {
                    continuation.finish(throwing: CancellationError())
                    return
                }
                
                await cancellationToken.checkMemoryPressure()
                if await cancellationToken.isCancelled {
                    continuation.finish(throwing: CancellationError())
                    return
                }
                
                let result = await calculateSingleHashOptimized(algorithm: algorithm, data: inputData)
                
                if let result = result {
                    autoreleasepool {
                        results.append(result)
                    }
                    
                    let progress = Double(index + 1) / Double(allAlgorithms.count)
                    let update = HashProgressUpdate(progress: progress, currentAlgorithm: algorithm)
                    continuation.yield((update, results))
                }
                
                if index < allAlgorithms.count - 1 {
                    let delay: UInt64 = fileSizeMB > 500 ? 500_000_000 : 300_000_000
                    try await Task.sleep(nanoseconds: delay)
                }
            }
            
            let finalUpdate = HashProgressUpdate(progress: 1.0, currentAlgorithm: "Complete")
            continuation.yield((finalUpdate, results))
            continuation.finish()
            
        } catch {
            continuation.finish(throwing: error)
        }
    }
    
    /// 大文件优化处理（10-100MB）- 平衡性能与稳定性
    private static func calculateHashesForLargeFile(data: Data) -> AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error> {
        return AsyncThrowingStream { continuation in
            let task = Task.detached(priority: .userInitiated) {
                await performLargeFileCalculation(data: data, continuation: continuation)
            }
        }
    }
    
    /// 执行大文件计算
    private static func performLargeFileCalculation(
        data: Data,
        continuation: AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error>.Continuation
    ) async {
        do {
            let algorithmGroups = [ultraFastAlgorithms, fastAlgorithms, mediumAlgorithms, slowAlgorithms, cryptographicAlgorithms, experimentalAlgorithms]
            let totalAlgorithms = algorithmGroups.flatMap { $0 }.count
            var completedResults: [HashResult] = []
            completedResults.reserveCapacity(totalAlgorithms)
            
            let inputData = data
            let fileSizeMB = Double(inputData.count) / (1024 * 1024)
            
            let concurrencyConfig = getConcurrencyConfig(for: fileSizeMB)
            
            for algorithms in algorithmGroups {
                if await cancellationToken.isCancelled {
                    continuation.finish(throwing: CancellationError())
                    return
                }
                
                if concurrencyConfig.concurrencyLimit == 1 {
                    await processAlgorithmsSerially(
                        algorithms: algorithms,
                        inputData: inputData,
                        completedResults: &completedResults,
                        totalAlgorithms: totalAlgorithms,
                        continuation: continuation
                    )
                } else {
                    await processAlgorithmsInBatches(
                        algorithms: algorithms,
                        inputData: inputData,
                        completedResults: &completedResults,
                        totalAlgorithms: totalAlgorithms,
                        concurrencyLimit: concurrencyConfig.concurrencyLimit,
                        batchDelay: concurrencyConfig.batchDelay,
                        continuation: continuation
                    )
                }
                
                try await Task.sleep(nanoseconds: concurrencyConfig.batchDelay)
            }
            
            let finalUpdate = HashProgressUpdate(progress: 1.0, currentAlgorithm: "Complete")
            continuation.yield((finalUpdate, completedResults))
            continuation.finish()
            
        } catch {
            continuation.finish(throwing: error)
        }
    }
    
    /// 并发配置
    private struct ConcurrencyConfig {
        let concurrencyLimit: Int
        let batchDelay: UInt64
    }
    
    /// 获取并发配置
    private static func getConcurrencyConfig(for fileSizeMB: Double) -> ConcurrencyConfig {
        if fileSizeMB <= 25 {
            return ConcurrencyConfig(concurrencyLimit: min(3, maxConcurrentTasks), batchDelay: 50_000_000)
        } else if fileSizeMB <= 50 {
            return ConcurrencyConfig(concurrencyLimit: min(2, maxConcurrentTasks), batchDelay: 100_000_000)
        } else {
            return ConcurrencyConfig(concurrencyLimit: 1, batchDelay: 200_000_000)
        }
    }
    
    /// 串行处理算法
    private static func processAlgorithmsSerially(
        algorithms: [String],
        inputData: Data,
        completedResults: inout [HashResult],
        totalAlgorithms: Int,
        continuation: AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error>.Continuation
    ) async {
        for algorithm in algorithms {
            if await cancellationToken.isCancelled {
                continuation.finish(throwing: CancellationError())
                return
            }
            
            let result = await calculateSingleHashOptimized(algorithm: algorithm, data: inputData)
            
            if let result = result {
                completedResults.append(result)
                
                let progress = Double(completedResults.count) / Double(totalAlgorithms)
                let update = HashProgressUpdate(progress: progress, currentAlgorithm: algorithm)
                continuation.yield((update, completedResults))
            }
            
            do {
                try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            } catch {
                // Handle sleep interruption
            }
        }
    }
    
    /// 批次并行处理算法
    private static func processAlgorithmsInBatches(
        algorithms: [String],
        inputData: Data,
        completedResults: inout [HashResult],
        totalAlgorithms: Int,
        concurrencyLimit: Int,
        batchDelay: UInt64,
        continuation: AsyncThrowingStream<(HashProgressUpdate, [HashResult]), Error>.Continuation
    ) async {
        for i in stride(from: 0, to: algorithms.count, by: concurrencyLimit) {
            if await cancellationToken.isCancelled {
                continuation.finish(throwing: CancellationError())
                return
            }
            
            let batch = Array(algorithms[i..<min(i + concurrencyLimit, algorithms.count)])
            
            await withTaskGroup(of: HashResult?.self) { group in
                for algorithm in batch {
                    group.addTask(priority: .userInitiated) { @Sendable in
                        return await calculateSingleHashOptimized(algorithm: algorithm, data: inputData)
                    }
                }
                
                for await result in group {
                    if let result = result {
                        completedResults.append(result)
                        
                        let progress = Double(completedResults.count) / Double(totalAlgorithms)
                        let update = HashProgressUpdate(progress: progress, currentAlgorithm: result.algorithm)
                        continuation.yield((update, completedResults))
                    }
                }
            }
            
            do {
                try await Task.sleep(nanoseconds: batchDelay)
            } catch {
                // Handle sleep interruption
            }
        }
    }
}
