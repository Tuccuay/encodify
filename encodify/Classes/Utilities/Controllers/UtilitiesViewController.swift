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
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // 设置内容间距以适应透明TabBar
        tableView.contentInsetAdjustmentBehavior = .automatic
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
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.top.bottom.equalToSuperview()
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
        cell.textLabel?.text = utility.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UtilitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let utility = utilities[indexPath.section][indexPath.row]
        let viewController = utility.viewControllerType.init()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
