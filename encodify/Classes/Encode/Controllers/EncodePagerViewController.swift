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
        setupModernStyling()
    }
    
    private func setupNavigationBar() {
        // Hide navigation bar since we have our own tab strip
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set background
        view.backgroundColor = UIColor.systemBackground
    }
    
    private func setupModernStyling() {
        // Add subtle blur effect to button bar
        if let buttonBarView = buttonBarView {
            // Add shadow
            buttonBarView.applyThemeAwareShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0, height: 1))
            
            // Add border at bottom
            let borderLayer = CALayer()
            borderLayer.backgroundColor = UIColor.encodifyBorderColor.cgColor
            borderLayer.frame = CGRect(x: 0, y: buttonBarView.frame.height - 0.5, width: buttonBarView.frame.width, height: 0.5)
            buttonBarView.layer.addSublayer(borderLayer)
        }
    }
    
    private func configurePagerTabStrip() {
        // Modern styling
        settings.style.buttonBarBackgroundColor = UIColor.systemBackground
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor.encodifyTintColor
        settings.style.buttonBarItemFont = UIFont.preferredFont(forTextStyle: .body)
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarMinimumInteritemSpacing = 0
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        
        // Text colors
        settings.style.buttonBarItemTitleColor = UIColor.encodifyPrimaryText
        
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        
        // Add modern background
        settings.style.buttonBarBackgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
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
