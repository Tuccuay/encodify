//
//  UtilityItem.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation
import UIKit

struct UtilityItem {
    let title: String
    let subtitle: String?
    let systemIcon: String?
    let viewControllerType: UIViewController.Type?
    
    init(title: String, 
         subtitle: String? = nil,
         systemIcon: String? = nil,
         viewControllerType: UIViewController.Type? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.systemIcon = systemIcon
        self.viewControllerType = viewControllerType
    }
}
