//
//  UtilitiesViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

class UtilitiesViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.backgroundColor = UIColor.clear
        
        return tableView
    }()
    
    private let utilities: [[UtilityItem]] = [
        [
            UtilityItem(title: "Image to Base64", 
                       subtitle: "Convert images to Base64 encoding",
                       systemIcon: "photo.on.rectangle.angled",
                       viewControllerType: ImageEncodeViewController.self),
            UtilityItem(title: "Base64 to Image", 
                       subtitle: "Decode Base64 data to images",
                       systemIcon: "photo.badge.plus",
                       viewControllerType: ImageDecodeViewController.self),
        ],
        [
            UtilityItem(title: "QR Code Generator", 
                       subtitle: "Generate QR codes from text",
                       systemIcon: "qrcode",
                       viewControllerType: nil), // 待实现
            UtilityItem(title: "Color Palette", 
                       subtitle: "Extract colors from text or images",
                       systemIcon: "paintpalette",
                       viewControllerType: nil), // 待实现
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Utilities"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Modern navigation bar setup
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource
extension UtilitiesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return utilities.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return utilities[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let utility = utilities[indexPath.section][indexPath.row]
        
        // 配置现代化的单元格样式
        var content = cell.defaultContentConfiguration()
        content.text = utility.title
        content.secondaryText = utility.subtitle
        
        // 设置字体样式
//        content.textProperties.font = UIFont.preferredFont(forTextStyle: .headline)
//        content.textProperties.color = UIColor.label
//        content.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .subheadline)
//        content.secondaryTextProperties.color = UIColor.secondaryLabel
        
        // 设置图标
        if let systemIcon = utility.systemIcon {
            content.image = UIImage(systemName: systemIcon)
            content.imageProperties.tintColor = UIColor.encodifyTintColor
//            content.imageProperties.cornerRadius = 8
        }
        
        cell.contentConfiguration = content
        cell.accessoryType = utility.viewControllerType != nil ? .disclosureIndicator : .none
        cell.backgroundColor = UIColor.secondarySystemGroupedBackground
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UtilitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        let utility = utilities[indexPath.section][indexPath.row]
        
        guard let viewControllerType = utility.viewControllerType else {
            // 显示"即将推出"提示
            Toast.showStatus("Coming soon!")
            return
        }
        
        let viewController = viewControllerType.init()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Add subtle entrance animation
        cell.transform = CGAffineTransform(translationX: 0, y: 20)
        cell.alpha = 0.8
        
        UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .allowUserInteraction) {
            cell.transform = CGAffineTransform.identity
            cell.alpha = 1.0
        }
    }
}
