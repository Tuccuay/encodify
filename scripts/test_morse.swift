#!/usr/bin/env swift

import Foundation

// 临时复制MorseEncoder的代码来进行测试
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
    
    /// 编码字符串为摩斯码（支持中文和英文）
    static func encode(_ string: String) -> String {
        return encode(string, options: .ui)
    }
    
    /// 解码摩斯码为字符串（支持中文和英文）
    static func decode(_ string: String) -> String {
        let processedString = string.replacingOccurrences(of: "   ", with: "/=/")
                                   .replacingOccurrences(of: " ", with: "/")
        
        return decode(processedString, options: .default)
    }
    
    static func encode(_ message: String, options: MorseOptions) -> String {
        let cleanedMessage = message.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
        let uppercasedMessage = cleanedMessage.uppercased()
        
        var morseResults: [String] = []
        
        for character in uppercasedMessage {
            let morseCode: String
            
            if let standardMorse = standardMorseMap[character] {
                morseCode = standardMorse
            } else {
                morseCode = unicodeToMorse(character)
            }
            
            let formattedMorse = morseCode
                .replacingOccurrences(of: "0", with: options.short)
                .replacingOccurrences(of: "1", with: options.long)
            
            morseResults.append(formattedMorse)
        }
        
        return morseResults.joined(separator: options.space)
    }
    
    static func decode(_ morse: String, options: MorseOptions) -> String {
        let morseArray = morse.components(separatedBy: options.space)
        var results: [String] = []
        
        for morseCode in morseArray {
            let cleanedMorse = morseCode.trimmingCharacters(in: .whitespaces)
            
            let binaryMorse = cleanedMorse
                .replacingOccurrences(of: options.short, with: "0")
                .replacingOccurrences(of: options.long, with: "1")
            
            let decodedChar: String
            
            if let standardChar = reverseMorseMap[binaryMorse] {
                decodedChar = String(standardChar)
            } else {
                decodedChar = morseToUnicode(binaryMorse)
            }
            
            results.append(decodedChar)
        }
        
        return results.joined()
    }
    
    private static func unicodeToMorse(_ character: Character) -> String {
        var unicodeHex = ""
        
        for scalar in character.unicodeScalars {
            let hexValue = String(format: "%04x", scalar.value)
            unicodeHex += hexValue
        }
        
        if let decimalValue = Int(unicodeHex, radix: 16) {
            return String(decimalValue, radix: 2)
        }
        
        return ""
    }
    
    private static func morseToUnicode(_ binaryMorse: String) -> String {
        guard let decimalValue = Int(binaryMorse, radix: 2) else {
            return ""
        }
        
        let hexString = String(format: "%x", decimalValue)
        
        let paddedHex = hexString.count % 4 == 0 ? hexString : 
                       String(repeating: "0", count: 4 - (hexString.count % 4)) + hexString
        
        var result = ""
        
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

// 测试代码
print("=== 摩斯码编码器测试 ===")

// 测试英文
let englishText = "HELLO"
let englishMorse = MorseEncoder.encode(englishText)
let decodedEnglish = MorseEncoder.decode(englishMorse)
print("英文测试:")
print("原文: \(englishText)")
print("摩斯码: \(englishMorse)")
print("解码: \(decodedEnglish)")
print("正确性: \(englishText.uppercased() == decodedEnglish ? "✅" : "❌")")
print()

// 测试数字
let numberText = "123"
let numberMorse = MorseEncoder.encode(numberText)
let decodedNumber = MorseEncoder.decode(numberMorse)
print("数字测试:")
print("原文: \(numberText)")
print("摩斯码: \(numberMorse)")
print("解码: \(decodedNumber)")
print("正确性: \(numberText == decodedNumber ? "✅" : "❌")")
print()

// 测试中文
let chineseText = "你好"
let chineseMorse = MorseEncoder.encode(chineseText)
let decodedChinese = MorseEncoder.decode(chineseMorse)
print("中文测试:")
print("原文: \(chineseText)")
print("摩斯码: \(chineseMorse)")
print("解码: \(decodedChinese)")
print("正确性: \(chineseText == decodedChinese ? "✅" : "❌")")
print()

// 测试混合文本
let mixedText = "HELLO你好123"
let mixedMorse = MorseEncoder.encode(mixedText)
let decodedMixed = MorseEncoder.decode(mixedMorse)
print("混合文本测试:")
print("原文: \(mixedText)")
print("摩斯码: \(mixedMorse)")
print("解码: \(decodedMixed)")
print("正确性: \(mixedText.uppercased() == decodedMixed ? "✅" : "❌")")

print("\n=== 测试完成 ===")
