//
//  DecodeViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class DecodeViewController: EncodeBaseViewController, IndicatorInfoProvider {
    
    // MARK: - IndicatorInfoProvider
    nonisolated func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Decode")
    }
    
    // MARK: - Override encoding methods
    override func encodeWithBase64(_ inputString: String) -> String? {
        return Base64Encoder.decode(inputString)
    }
    
    override func encodeWithUnicode(_ inputString: String) -> String? {
        return UnicodeEncoder.decode(inputString)
    }
    
    override func encodeWithMorse(_ inputString: String) -> String? {
        return MorseEncoder.decode(inputString)
    }
    
    override func encodeWithURI(_ inputString: String) -> String? {
        return URLEncoder.decode(inputString)
    }
    
    override var encodeButtonTitle: String {
        return "Decode"
    }
}
