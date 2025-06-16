//
//  ROT13Encoder.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation

struct ROT13Encoder {
    static func encode(_ string: String) -> String {
        let characters = string.map { char -> Character in
            if char.isLetter {
                let isUppercase = char.isUppercase
                let asciiOffset: UInt8 = isUppercase ? 65 : 97
                let rotated = ((char.asciiValue! - asciiOffset + 13) % 26) + asciiOffset
                return Character(UnicodeScalar(rotated))
            }
            return char
        }
        
        return characters.map(String.init).joined()
    }
    
    static func decode(_ string: String) -> String {
        // ROT13 is symmetric, so decoding is the same as encoding
        return encode(string)
    }
}
