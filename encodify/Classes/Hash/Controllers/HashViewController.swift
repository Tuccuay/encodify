//
//  HashViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit
import UniformTypeIdentifiers

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
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HashResultTableViewCell.self, forCellReuseIdentifier: "HashResultCell")
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        // 设置内容间距以适应透明TabBar
        tableView.contentInsetAdjustmentBehavior = .automatic
        // 添加滑动收起键盘功能
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private lazy var showTypeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Lowercase", "Uppercase", "Base64"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(showTypeChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy", for: .normal)
        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var pasteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Paste", for: .normal)
        button.addTarget(self, action: #selector(pasteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var hashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hash", for: .normal)
        button.addTarget(self, action: #selector(hashButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var hashResults: [HashResult] = []
    private var currentHashTask: Task<Void, Never>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToResign))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        title = "Hash"
        view.backgroundColor = .systemBackground
        
        view.addSubview(showTypeSegmentedControl)
        view.addSubview(inputTextView)
        view.addSubview(buttonStackView)
        view.addSubview(tableView)
        
        // 设置按钮堆栈
        buttonStackView.addArrangedSubview(copyButton)
        buttonStackView.addArrangedSubview(pasteButton)
        buttonStackView.addArrangedSubview(clearButton)
        buttonStackView.addArrangedSubview(hashButton)
        
        setContentScrollView(tableView)
        
        showTypeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(32)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(showTypeSegmentedControl.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(120)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(8)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc private func showTypeChanged() {
        // 格式类型改变时立即重新加载表格，无需重新计算哈希
        tableView.reloadData()
    }
    
    @objc private func copyButtonTapped() {
        inputTextView.resignFirstResponder()
        
        guard let text = inputTextView.text, !text.isEmpty else {
            Toast.showError("No text to copy")
            return
        }
        
        UIPasteboard.general.string = text
        Toast.showStatus("Copied")
    }
    
    @objc private func pasteButtonTapped() {
        inputTextView.resignFirstResponder()
        
        guard let text = UIPasteboard.general.string else {
            Toast.showError("No text in clipboard")
            return
        }
        
        inputTextView.text = text
        calculateHashesImmediately()
        Toast.showStatus("Pasted")
    }
    
    @objc private func clearButtonTapped() {
        inputTextView.resignFirstResponder()
        inputTextView.text = ""
        
        // 取消正在进行的哈希计算
        currentHashTask?.cancel()
        hashResults = []
        tableView.reloadData()
        
        Toast.showStatus("Cleared")
    }
    
    @objc private func hashButtonTapped() {
        inputTextView.resignFirstResponder()
        calculateHashesImmediately()
        if !hashResults.isEmpty {
            Toast.showStatus("Hashed")
        }
    }
    
    @objc private func resignTextView() {
        inputTextView.resignFirstResponder()
    }
    
    @objc private func tapToResign() {
        inputTextView.resignFirstResponder()
    }
    
    private func calculateHashes() {
        guard let text = inputTextView.text, !text.isEmpty else {
            hashResults = []
            tableView.reloadData()
            return
        }
        
        // 取消之前的计算任务
        currentHashTask?.cancel()
        
        // 使用 Task 来处理异步计算
        currentHashTask = Task {
            // 添加防抖延迟
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            // 检查是否被取消
            guard !Task.isCancelled else { return }
            
            // 在后台计算哈希
            let results = await Task.detached {
                return HashCalculator.calculateHashes(for: text)
            }.value
            
            // 检查是否被取消
            guard !Task.isCancelled else { return }
            
            // 回到主线程更新UI
            await MainActor.run {
                self.hashResults = results
                self.tableView.reloadData()
            }
        }
    }
    
    private func calculateHashesImmediately() {
        guard let text = inputTextView.text, !text.isEmpty else {
            hashResults = []
            tableView.reloadData()
            return
        }
        
        // 取消之前的计算任务
        currentHashTask?.cancel()
        
        // 立即计算，不延迟
        currentHashTask = Task {
            // 在后台计算哈希
            let results = await Task.detached {
                return HashCalculator.calculateHashes(for: text)
            }.value
            
            // 检查是否被取消
            guard !Task.isCancelled else { return }
            
            // 回到主线程更新UI
            await MainActor.run {
                self.hashResults = results
                self.tableView.reloadData()
            }
        }
    }
    
    private func formattedHash(_ hash: String) -> String {
        switch showTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            return hash.lowercased()
        case 1:
            return hash.uppercased()
        case 2:
            // 将十六进制字符串转换为 base64
            return hexStringToBase64(hash) ?? hash.lowercased()
        default:
            return hash.lowercased()
        }
    }
    
    private func hexStringToBase64(_ hexString: String) -> String? {
        // 移除可能存在的空格和换行符
        let cleanHex = hexString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        
        // 确保十六进制字符串长度是偶数
        guard cleanHex.count % 2 == 0 else { return nil }
        
        var data = Data()
        var index = cleanHex.startIndex
        
        // 将十六进制字符串转换为 Data
        while index < cleanHex.endIndex {
            let nextIndex = cleanHex.index(index, offsetBy: 2)
            let byteString = String(cleanHex[index..<nextIndex])
            
            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            data.append(byte)
            
            index = nextIndex
        }
        
        // 转换为 base64
        return data.base64EncodedString()
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
        let hashToCopy = formattedHash(result.hash)
        UIPasteboard.general.string = hashToCopy
        
        // Toast 方法已经标记为 @MainActor，可以直接调用
        Toast.showStatus("Copied")
    }
}
