//
//  EncodePagerViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class EncodePagerViewController: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        configurePagerTabStrip()
        super.viewDidLoad()
        setupAppearance()
    }
    
    private func configurePagerTabStrip() {
        settings.style.buttonBarBackgroundColor = UIColor.navigationBarDefaultColor
        settings.style.buttonBarItemBackgroundColor = UIColor.navigationBarDefaultColor
        settings.style.selectedBarBackgroundColor = UIColor.encodifyTintColor
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 16)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
    }
    
    private func setupAppearance() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Adjust button bar frame for status bar
        if let buttonBarView = buttonBarView {
            var frame = buttonBarView.frame
            frame.origin.y += 20
            buttonBarView.frame = frame
        }
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let encodeViewController = EncodeViewController()
        let decodeViewController = DecodeViewController()
        return [encodeViewController, decodeViewController]
    }
}
