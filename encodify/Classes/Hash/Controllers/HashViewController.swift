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
    
    private let placeholderText = "Enter text to calculate hash values..."
    
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = UIColor.encodifyCardBackground
        textView.textColor = UIColor.encodifyPrimaryText
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = false
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.delegate = self
        
        // Use theme-aware shadow instead of hardcoded black
        textView.applyThemeAwareShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        // Accessibility improvements
        textView.accessibilityLabel = "Input text for hashing"
        textView.accessibilityHint = "Enter text here to generate hash values"
        
        return textView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HashResultTableViewCell.self, forCellReuseIdentifier: "HashResultCell")
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.systemBackground
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.keyboardDismissMode = .onDrag
        
        // Modern appearance
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        return tableView
    }()
    
    private lazy var showTypeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Lowercase", "Uppercase", "Base64"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(showTypeChanged), for: .valueChanged)
        
        // Modern styling with updated appearance
        control.backgroundColor = UIColor.encodifyCardBackground
        control.selectedSegmentTintColor = UIColor.encodifyTintColor
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.encodifyPrimaryText,
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ], for: .normal)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ], for: .selected)
        
        control.layer.cornerRadius = 10
        control.applyThemeAwareShadow(radius: 4, opacity: 0.08, offset: CGSize(width: 0, height: 1))
        
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
    
    private lazy var pasteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Paste", for: .normal)
        button.addTarget(self, action: #selector(pasteButtonTapped), for: .touchUpInside)
        
        // Modern button styling
        button.backgroundColor = UIColor.encodifySecondaryColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = false
        
        // Add subtle shadow and depth
        button.layer.shadowColor = UIColor.encodifySecondaryColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.3
        
        // Haptic feedback
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        // Destructive button styling
        button.backgroundColor = UIColor.encodifyDestructiveBackground
        button.setTitleColor(UIColor.encodifyErrorColor, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 12
        button.applyThemeAwareShadow(radius: 4, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        
        // Haptic feedback
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        
        return button
    }()
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Add visual feedback with spring animation
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .allowUserInteraction) {
                sender.transform = CGAffineTransform.identity
            }
        }
    }
    
    private var hashResults: [HashResult] = []
    private var currentHashTask: Task<Void, Never>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        setupPlaceholder()
        
        print("viewDidLoad")
        inputTextView.debugPlaceholderAlignment()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
        inputTextView.debugPlaceholderAlignment()
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToResign))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        title = "Hash"
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(showTypeSegmentedControl)
        view.addSubview(inputTextView)
        view.addSubview(buttonStackView)
        view.addSubview(tableView)
        setContentScrollView(tableView)
        
        // 设置按钮堆栈
        buttonStackView.addArrangedSubview(pasteButton)
        buttonStackView.addArrangedSubview(clearButton)
        
        // 设置约束
        
        showTypeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(showTypeSegmentedControl.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(120) // 固定高度而不是最小高度
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(20)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        // 添加入场动画
        let allViews = [showTypeSegmentedControl, inputTextView, buttonStackView, tableView]
        allViews.forEach { view in
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            allViews.forEach { view in
                view.alpha = 1
                view.transform = .identity
            }
        }
    }
    
    private func setupPlaceholder() {
        inputTextView.setPlaceholder(placeholderText, style: .inputPlaceholder)
        // 手动设置与 UITextView contentInset 一致的 padding
        inputTextView.setPlaceholderPadding(16)
    }
    
    @objc private func showTypeChanged() {
        // 格式类型改变时立即重新加载表格，无需重新计算哈希
        tableView.reloadData()
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
    
    // MARK: - Theme Support (系统自动处理主题变化)
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // 仅在必要时手动更新主题相关组件
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateThemeAwareComponents()
        }
    }
    
    private func updateThemeAwareComponents() {
        let colors = ThemeManager.shared.getCurrentThemeColors()
        
        // Update input text view
        inputTextView.backgroundColor = colors.cardBackground
        inputTextView.textColor = colors.primaryText
        inputTextView.applyThemeAwareShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        // Update table view
        tableView.backgroundColor = colors.primaryBackground
        
        // Update placeholder appearance
        inputTextView.applyThemeToPlaceholder()
        
        // Reload table view to update cells
        tableView.reloadData()
    }
}

// MARK: - UITextViewDelegate
extension HashViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        calculateHashes()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Add subtle scale animation when focused
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            textView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Reset scale when unfocused
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            textView.transform = .identity
        }
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
