//
//  BinaryEncoder.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation

struct BinaryEncoder {
    static func encode(_ string: String) -> String {
        return string.data(using: .utf8)?.map { 
            String($0, radix: 2).padding(toLength: 8, withPad: "0", startingAt: 0)
        }.joined(separator: " ") ?? ""
    }
    
    static func decode(_ binaryString: String) -> String? {
        let binaryChunks = binaryString.components(separatedBy: " ")
        var data = Data()
        
        for chunk in binaryChunks {
            guard chunk.count == 8, let byte = UInt8(chunk, radix: 2) else { return nil }
            data.append(byte)
        }
        
        return String(data: data, encoding: .utf8)
    }
}
