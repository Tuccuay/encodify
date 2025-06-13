//
//  URLEncoder.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation

struct URLEncoder {
    static func encode(_ string: String) -> String? {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    static func decode(_ string: String) -> String? {
        return string.removingPercentEncoding
    }
}
