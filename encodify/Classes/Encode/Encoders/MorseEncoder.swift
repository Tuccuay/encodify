//
//  MorseEncoder.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation

enum MorseCodeData {
    case singleSpace // 1 pause
    case dit // 1 beep
    case dah // 3 beeps
    case threeSpaces // 3 pauses
}

struct MorseEncoder {
    
    // MARK: - Constants
    private static let standardMorseMap: [Character: String] = [
        // Letters
        "A": "01", "B": "1000", "C": "1010", "D": "100", "E": "0",
        "F": "0010", "G": "110", "H": "0000", "I": "00", "J": "0111",
        "K": "101", "L": "0100", "M": "11", "N": "10", "O": "111",
        "P": "0110", "Q": "1101", "R": "010", "S": "000", "T": "1",
        "U": "001", "V": "0001", "W": "011", "X": "1001", "Y": "1011", "Z": "1100",
        
        // Numbers
        "0": "11111", "1": "01111", "2": "00111", "3": "00011", "4": "00001",
        "5": "00000", "6": "10000", "7": "11000", "8": "11100", "9": "11110",
        
        // Punctuation
        ".": "010101", ",": "110011", "?": "001100", "'": "011110", "!": "101011",
        "/": "10010", "(": "10110", ")": "101101", "&": "01000", ":": "111000",
        ";": "101010", "=": "10001", "+": "01010", "-": "100001", "_": "001101",
        "\"": "010010", "$": "0001001", "@": "011010"
    ]
    
    private static let reverseMorseMap: [String: Character] = {
        var reverseMap: [String: Character] = [:]
        for (char, morse) in standardMorseMap {
            reverseMap[morse] = char
        }
        return reverseMap
    }()
    
    struct MorseOptions {
        let space: String
        let short: String
        let long: String
        
        static let `default` = MorseOptions(space: "/", short: ".", long: "-")
        static let ui = MorseOptions(space: " ", short: ".", long: "-")
    }
    
    // MARK: - Public Methods
    
    /// 编码字符串为摩斯码（支持中文和英文）
    /// - Parameter string: 要编码的字符串
    /// - Returns: 摩斯码字符串
    static func encode(_ string: String) -> String {
        return encode(string, options: .ui)
    }
    
    /// 解码摩斯码为字符串（支持中文和英文）
    /// - Parameter string: 摩斯码字符串
    /// - Returns: 解码后的字符串
    static func decode(_ string: String) -> String {
        // 处理输入的摩斯码格式：三个空格表示字符间分隔，一个空格表示字母内分隔
        let processedString = string.replacingOccurrences(of: "   ", with: "/=/")
                                   .replacingOccurrences(of: " ", with: "/")
        
        return decode(processedString, options: .default)
    }
    
    /// 编码字符串为摩斯码（支持中文）
    /// - Parameters:
    ///   - message: 要编码的字符串
    ///   - options: 摩斯码选项
    /// - Returns: 摩斯码字符串
    static func encode(_ message: String, options: MorseOptions) -> String {
        let cleanedMessage = message.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        let uppercasedMessage = cleanedMessage.uppercased()
        
        var morseResults: [String] = []
        
        for character in uppercasedMessage {
            let morseCode: String
            
            if let standardMorse = standardMorseMap[character] {
                // 标准字符使用预定义的摩斯编码
                morseCode = standardMorse
            } else {
                // 非标准字符（如中文）使用 Unicode 编码
                morseCode = unicodeToMorse(character)
            }
            
            // 将 0 替换为短信号，1 替换为长信号
            let formattedMorse = morseCode
                .replacingOccurrences(of: "0", with: options.short)
                .replacingOccurrences(of: "1", with: options.long)
            
            morseResults.append(formattedMorse)
        }
        
        return morseResults.joined(separator: options.space)
    }
    
    /// 解码摩斯码为字符串（支持中文）
    /// - Parameters:
    ///   - morse: 摩斯码字符串
    ///   - options: 摩斯码选项
    /// - Returns: 解码后的字符串
    static func decode(_ morse: String, options: MorseOptions) -> String {
        let morseArray = morse.components(separatedBy: options.space)
        var results: [String] = []
        
        for morseCode in morseArray {
            let cleanedMorse = morseCode.trimmingCharacters(in: .whitespaces)
            
            // 将短长信号转换回 0 1
            let binaryMorse = cleanedMorse
                .replacingOccurrences(of: options.short, with: "0")
                .replacingOccurrences(of: options.long, with: "1")
            
            let decodedChar: String
            
            if let standardChar = reverseMorseMap[binaryMorse] {
                // 标准字符
                decodedChar = String(standardChar)
            } else {
                // 非标准字符（Unicode 解码）
                decodedChar = morseToUnicode(binaryMorse)
            }
            
            results.append(decodedChar)
        }
        
        return results.joined()
    }
    
    // MARK: - Private Methods
    
    /// 将字符转换为 Unicode 十六进制再转为二进制摩斯码
    private static func unicodeToMorse(_ character: Character) -> String {
        var unicodeHex = ""
        
        // 获取字符的所有 Unicode 标量值
        for scalar in character.unicodeScalars {
            let hexValue = String(format: "%04x", scalar.value)
            unicodeHex += hexValue
        }
        
        // 将十六进制转为十进制，再转为二进制
        if let decimalValue = Int(unicodeHex, radix: 16) {
            return String(decimalValue, radix: 2)
        }
        
        return ""
    }
    
    /// 将二进制摩斯码转换回 Unicode 字符
    private static func morseToUnicode(_ binaryMorse: String) -> String {
        // 将二进制转为十进制
        guard let decimalValue = Int(binaryMorse, radix: 2) else {
            return ""
        }
        
        // 转为十六进制
        let hexString = String(format: "%x", decimalValue)
        
        // 确保是 4 的倍数（Unicode 码点的长度）
        let paddedHex = hexString.count % 4 == 0 ? hexString : 
                       String(repeating: "0", count: 4 - (hexString.count % 4)) + hexString
        
        var result = ""
        
        // 每 4 个字符为一组，转换为 Unicode 字符
        for i in stride(from: 0, to: paddedHex.count, by: 4) {
            let startIndex = paddedHex.index(paddedHex.startIndex, offsetBy: i)
            let endIndex = paddedHex.index(startIndex, offsetBy: 4)
            let hexChunk = String(paddedHex[startIndex..<endIndex])
            
            if let unicodeValue = UInt32(hexChunk, radix: 16),
               let scalar = UnicodeScalar(unicodeValue) {
                result += String(scalar)
            }
        }
        
        return result
    }
}
