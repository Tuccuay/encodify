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
    let viewControllerType: UIViewController.Type
    
    init(title: String, viewControllerType: UIViewController.Type) {
        self.title = title
        self.viewControllerType = viewControllerType
    }
}
