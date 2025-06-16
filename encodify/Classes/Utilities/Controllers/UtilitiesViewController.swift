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
        tableView.backgroundColor = UIColor.systemBackground
        tableView.separatorStyle = .none
        
        // Modern appearance configuration
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        return tableView
    }()
    
    private let utilities: [[UtilityItem]] = [
        [
            UtilityItem(title: "Pick image & encode to base64", viewControllerType: ImageEncodeViewController.self),
            UtilityItem(title: "Decode base64 to image", viewControllerType: ImageDecodeViewController.self),
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Utilities"
        view.backgroundColor = UIColor.systemBackground
        
        // Modern navigation bar setup
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
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
        
        // Configure cell with modern styling
        cell.textLabel?.text = utility.title
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.textColor = UIColor.encodifyPrimaryText
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.encodifyCardBackground
        cell.selectionStyle = .none
        
        // Add subtle shadow and rounded corners
        cell.layer.cornerRadius = 12
        cell.applyThemeAwareShadow(radius: 4, opacity: 0.08, offset: CGSize(width: 0, height: 1))
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UtilitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        let utility = utilities[indexPath.section][indexPath.row]
        let viewController = utility.viewControllerType.init()
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
