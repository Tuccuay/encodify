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
        
        setupNavigationBar()
        setupButtonBarConstraints()
    }
    
    private func setupNavigationBar() {
        // Hide navigation bar since we have our own tab strip
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func configurePagerTabStrip() {
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor.encodifyTintColor
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 16)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .label
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
    }
    
    private func setupButtonBarConstraints() {
        // Configure button bar to stick to safe area top
        if let buttonBarView = buttonBarView {
            buttonBarView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                buttonBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                buttonBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                buttonBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                buttonBarView.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        // Configure container view to be below button bar
        if let containerView = containerView, let buttonBarView = buttonBarView {
            containerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: buttonBarView.bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }
    
    private func adjustButtonBarLayout() {
        // No manual adjustment needed when using proper constraints
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let encodeViewController = EncodeViewController()
        let decodeViewController = DecodeViewController()
        return [encodeViewController, decodeViewController]
    }
}
