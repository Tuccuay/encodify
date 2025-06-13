//
//  EncodeViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class EncodeViewController: EncodeBaseViewController, IndicatorInfoProvider {
    
    // MARK: - IndicatorInfoProvider
    nonisolated func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Encode")
    }
    
    // MARK: - Override encoding methods
    override func encodeWithBase64(_ inputString: String) -> String? {
        return Base64Encoder.encode(inputString)
    }
    
    override func encodeWithUnicode(_ inputString: String) -> String? {
        return UnicodeEncoder.encode(inputString)
    }
    
    override func encodeWithMorse(_ inputString: String) -> String? {
        return MorseEncoder.encode(inputString)
    }
    
    override func encodeWithURI(_ inputString: String) -> String? {
        return URLEncoder.encode(inputString)
    }
    
    override var encodeButtonTitle: String {
        return "Encode"
    }
}
