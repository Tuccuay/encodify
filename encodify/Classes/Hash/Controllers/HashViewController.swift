//
//  HashViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

class HashViewController: UIViewController {
    
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 4
        textView.delegate = self
        return textView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HashResultTableViewCell.self, forCellReuseIdentifier: "HashResultCell")
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var showTypeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Lowercase", "Uppercase"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(showTypeChanged), for: .valueChanged)
        return control
    }()
    
    private var hashResults: [HashResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Hash"
        
        view.addSubview(inputTextView)
        view.addSubview(showTypeSegmentedControl)
        view.addSubview(tableView)
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(120)
        }
        
        showTypeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(32)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(showTypeSegmentedControl.snp.bottom).offset(8)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignTextView))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func showTypeChanged() {
        tableView.reloadData()
    }
    
    @objc private func resignTextView() {
        inputTextView.resignFirstResponder()
    }
    
    private func calculateHashes() {
        guard let text = inputTextView.text, !text.isEmpty else {
            hashResults = []
            tableView.reloadData()
            return
        }
        
        hashResults = HashCalculator.calculateHashes(for: text)
        tableView.reloadData()
    }
    
    private func formattedHash(_ hash: String) -> String {
        return showTypeSegmentedControl.selectedSegmentIndex == 0 ? hash.lowercased() : hash.uppercased()
    }
}

// MARK: - UITextViewDelegate
extension HashViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        calculateHashes()
    }
}

// MARK: - UITableViewDataSource
extension HashViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HashResultCell", for: indexPath) as! HashResultTableViewCell
        let result = hashResults[indexPath.row]
        cell.configure(algorithm: result.algorithm, hash: formattedHash(result.hash))
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HashViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        inputTextView.resignFirstResponder()
        
        let result = hashResults[indexPath.row]
        UIPasteboard.general.string = formattedHash(result.hash)
        Toast.showStatus("Copied")
    }
}

// MARK: - UIGestureRecognizerDelegate
extension HashViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !touch.view!.isKind(of: UITableViewCell.self)
    }
}
