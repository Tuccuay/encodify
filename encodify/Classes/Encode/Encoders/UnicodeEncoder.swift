//
//  UnicodeEncoder.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation

struct UnicodeEncoder {
    static func encode(_ string: String) -> String {
        var result = ""
        
        for character in string {
            let scalar = character.unicodeScalars.first!
            let unicodeValue = scalar.value
            result += String(format: "\\u%04x", unicodeValue)
        }
        
        return result
    }
    
    static func decode(_ string: String) -> String? {
        // Replace \u with \U for property list parsing
        let tempStr1 = string.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"\(tempStr2)\""
        
        guard let data = tempStr3.data(using: .utf8) else { return nil }
        
        do {
            if let result = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? String {
                return result.replacingOccurrences(of: "\\r\\n", with: "\n")
            }
        } catch {
            return nil
        }
        
        return nil
    }
}
