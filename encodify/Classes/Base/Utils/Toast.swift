//
//  Toast.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class Toast {
    @MainActor
    static func showStatus(_ message: String) {
        let banner = StatusBarNotificationBanner(title: message, style: .info)
        banner.backgroundColor = UIColor.encodifyTintColor
        banner.duration = 0.6
        banner.show()
    }
    
    @MainActor
    static func showError(_ message: String) {
        let banner = StatusBarNotificationBanner(title: message, style: .danger)
        banner.duration = 0.6
        banner.show()
    }
}
