//
//  HexEncoder.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation

struct HexEncoder {
    static func encode(_ string: String) -> String {
        return string.data(using: .utf8)?.map { String(format: "%02x", $0) }.joined() ?? ""
    }
    
    static func decode(_ hexString: String) -> String? {
        guard hexString.count % 2 == 0 else { return nil }
        
        var data = Data()
        var index = hexString.startIndex
        
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            let byteString = String(hexString[index..<nextIndex])
            
            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            data.append(byte)
            
            index = nextIndex
        }
        
        return String(data: data, encoding: .utf8)
    }
}
