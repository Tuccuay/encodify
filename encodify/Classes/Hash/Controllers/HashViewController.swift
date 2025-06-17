//
//  HashViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

/// 现代化的哈希计算控制器
/// 提供分组展示和更好的用户体验
class HashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let hashGroups = HashAlgorithm.allAlgorithms
    private var hashResults: [String: String] = [:]  // [algorithmKey: hashValue]
    
    private lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.applyThemeAwareShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        return view
    }()
    
    private lazy var inputHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var inputHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = UIColor.label
        label.text = "Input Text"
        return label
    }()
    
    private lazy var inputFullScreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        button.addTarget(self, action: #selector(showInputFullScreen), for: .touchUpInside)
        return button
    }()
    
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = .clear
        textView.textColor = UIColor.label
        textView.delegate = self
        
        // 设置占位符
        textView.setPlaceholder("Enter text to calculate hash values...", style: .inputPlaceholder)
        textView.setPlaceholderPadding(0)
        
        return textView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HashCell.self, forCellReuseIdentifier: "HashCell")
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.keyboardDismissMode = .onDrag
        
        return tableView
    }()
    
    private lazy var calculateButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Calculate All Hashes"
        config.baseBackgroundColor = UIColor.encodifyTintColor
        config.baseForegroundColor = UIColor.white
        config.cornerStyle = .medium
        config.buttonSize = .large
        config.image = UIImage(systemName: "lock.shield")
        config.imagePadding = 8
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
            return outgoing
        }
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(calculateHashes), for: .touchUpInside)
        
        return button
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // 添加点击手势以收起键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // 创建顶部内容容器视图 - 使用卡片样式
        let topContainerView = UIView()
        topContainerView.backgroundColor = UIColor.secondarySystemGroupedBackground
        topContainerView.layer.cornerRadius = 16
        topContainerView.applyThemeAwareShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        // 添加视图层次
        view.addSubview(topContainerView)
        view.addSubview(tableView)
        
        setContentScrollView(tableView)
        
        topContainerView.addSubview(showTypeSegmentedControl)
        topContainerView.addSubview(inputContainerView)
        topContainerView.addSubview(calculateButton)
        
        // 输入容器内容
        inputContainerView.addSubview(inputHeaderView)
        inputContainerView.addSubview(inputTextView)
        
        // 输入头部
        inputHeaderView.addSubview(inputHeaderLabel)
        inputHeaderView.addSubview(inputFullScreenButton)
        
        // 设置顶部容器约束 - 固定在顶部
        topContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        showTypeSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        
        inputContainerView.snp.makeConstraints { make in
            make.top.equalTo(showTypeSegmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        inputHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        inputHeaderLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        inputFullScreenButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(24)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(inputHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
        
        calculateButton.snp.makeConstraints { make in
            make.top.equalTo(inputContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // TableView 占用剩余空间，可以滚动
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        
        // 添加入场动画
        let allViews = [topContainerView, tableView]
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
    
    // MARK: - Helper Methods
    
    private func setupNavigationBar() {
        title = "Hash Calculator"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        // 添加工具栏按钮
        let clearButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(clearAll)
        )
        
        let pasteButton = UIBarButtonItem(
            image: UIImage(systemName: "doc.on.clipboard"),
            style: .plain,
            target: self,
            action: #selector(pasteText)
        )
        
        navigationItem.rightBarButtonItems = [clearButton, pasteButton]
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.tableView.contentInset.bottom = keyboardHeight - safeAreaBottom
            self?.tableView.verticalScrollIndicatorInsets.bottom = keyboardHeight - safeAreaBottom
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.tableView.contentInset.bottom = 0
            self?.tableView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func calculateHashes() {
        // 收起键盘
        view.endEditing(true)
        
        guard let inputText = inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !inputText.isEmpty else {
            Toast.showError("Please enter text to hash")
            return
        }
        
        // 显示加载状态
        var config = calculateButton.configuration ?? UIButton.Configuration.filled()
        config.showsActivityIndicator = true
        config.title = "Calculating..."
        calculateButton.configuration = config
        calculateButton.isEnabled = false
        
        // 异步计算哈希
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // 计算所有哈希算法
            let allResults = HashCalculator.calculateHashes(for: inputText)
            var results: [String: String] = [:]
            
            // 将结果映射到我们需要的算法
            for result in allResults {
                results[result.algorithm] = result.hash
            }
            
            DispatchQueue.main.async {
                self?.hashResults = results
                self?.tableView.reloadData()
                
                // 恢复按钮状态
                var config = self?.calculateButton.configuration ?? UIButton.Configuration.filled()
                config.showsActivityIndicator = false
                config.title = "Calculate All Hashes"
                self?.calculateButton.configuration = config
                self?.calculateButton.isEnabled = true
                
                // 成功反馈
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.notificationOccurred(.success)
                
                Toast.showStatus("Hashes calculated successfully")
            }
        }
    }
    
    @objc private func clearAll() {
        // 收起键盘
        view.endEditing(true)
        
        inputTextView.text = ""
        hashResults.removeAll()
        tableView.reloadData()
        
        Toast.showStatus("Cleared all data")
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    @objc private func pasteText() {
        // 收起键盘
        view.endEditing(true)
        
        guard let text = UIPasteboard.general.string else {
            Toast.showError("No text in clipboard")
            return
        }
        
        inputTextView.text = text
        Toast.showStatus("Text pasted")
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    @objc private func showTypeChanged() {
        // 格式类型改变时立即重新加载表格，无需重新计算哈希
        tableView.reloadData()
    }
    
    @objc private func showInputFullScreen() {
        let fullScreenVC = FullScreenTextViewController(
            text: inputTextView.text ?? "",
            title: "Input Text",
            placeholder: "Enter text to calculate hash values...",
            isReadOnly: false
        )
        
        fullScreenVC.onTextChanged = { [weak self] text in
            self?.inputTextView.text = text
            // 清空之前的结果
            self?.hashResults.removeAll()
            self?.tableView.reloadData()
        }
        
        fullScreenVC.onShare = { [weak self] text in
            self?.shareText(text, from: "Input Text")
        }
        
        fullScreenVC.onCopy = { [weak self] text in
            self?.copyText(text, from: "Input Text")
        }
        
        let navController = UINavigationController(rootViewController: fullScreenVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func shareText(_ text: String, from source: String) {
        guard !text.isEmpty else {
            Toast.showError("No content to share")
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        // iPad 支持
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }
    
    private func copyText(_ text: String, from source: String) {
        guard !text.isEmpty else {
            Toast.showError("No content to copy")
            return
        }
        
        UIPasteboard.general.string = text
        Toast.showStatus("Copied to clipboard")
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
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
        // 清空之前的结果
        hashResults.removeAll()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension HashViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return hashGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashGroups[section].algorithms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HashCell", for: indexPath) as! HashCell
        let algorithm = hashGroups[indexPath.section].algorithms[indexPath.row]
        let rawHashValue = hashResults[algorithm.algorithmKey]
        let formattedHashValue = rawHashValue != nil ? formattedHash(rawHashValue!) : nil
        
        cell.configure(with: algorithm, hashValue: formattedHashValue)
        
        // 设置长按手势查看哈希值全屏
        cell.onLongPress = { [weak self] in
            guard let strongSelf = self, let hashValue = formattedHashValue else {
                Toast.showError("No hash value available. Please calculate hashes first.")
                return
            }
            
            let fullScreenVC = FullScreenTextViewController(
                text: hashValue,
                title: "\(algorithm.name) Hash Result",
                isReadOnly: true
            )
            
            fullScreenVC.onShare = { [weak self] text in
                self?.shareText(text, from: "\(algorithm.name) Hash")
            }
            
            fullScreenVC.onCopy = { [weak self] text in
                self?.copyText(text, from: "\(algorithm.name) Hash")
            }
            
            let navController = UINavigationController(rootViewController: fullScreenVC)
            navController.modalPresentationStyle = .fullScreen
            strongSelf.present(navController, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return hashGroups[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return hashGroups[section].subtitle
    }
}

// MARK: - UITableViewDelegate

extension HashViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let algorithm = hashGroups[indexPath.section].algorithms[indexPath.row]
        
        guard let rawHashValue = hashResults[algorithm.algorithmKey] else {
            Toast.showError("No hash value available. Please calculate hashes first.")
            return
        }
        
        let formattedHashValue = formattedHash(rawHashValue)
        UIPasteboard.general.string = formattedHashValue
        Toast.showStatus("\(algorithm.name) hash copied to clipboard")
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // 只在最后一个 section 显示总结信息
        guard section == hashGroups.count - 1 else { return nil }
        
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        
        let infoLabel = UILabel()
        infoLabel.text = "🔐 Total: 20 hash algorithms supported\n✅ Secure algorithms for modern use\n⚠️ Legacy algorithms for compatibility\n🔗 Blockchain algorithms for crypto\n📊 Checksums for data integrity"
        infoLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        infoLabel.textColor = UIColor.secondaryLabel
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.adjustsFontForContentSizeCategory = true
        
        footerView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // 只在最后一个 section 设置高度
        return section == hashGroups.count - 1 ? UITableView.automaticDimension : 0
    }
}

// MARK: - Modern Hash Cell

class HashCell: UITableViewCell {
    
    // MARK: - Properties
    
    /// 长按回调
    var onLongPress: (() -> Void)?
    
    private lazy var algorithmLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor.label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = UIColor.secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var hashLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize, weight: .regular)
        label.textColor = UIColor.label
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private lazy var securityBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        
        let label = UILabel()
        label.text = "SECURE"
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = UIColor.systemGreen
        label.adjustsFontForContentSizeCategory = true
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        return view
    }()
    
    private lazy var legacyBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
        
        let label = UILabel()
        label.text = "LEGACY"
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = UIColor.systemOrange
        label.adjustsFontForContentSizeCategory = true
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        return view
    }()
    
    private lazy var checksumBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        
        let label = UILabel()
        label.text = "CHECKSUM"
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = UIColor.systemBlue
        label.adjustsFontForContentSizeCategory = true
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        return view
    }()
    
    private lazy var blockchainBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        
        let label = UILabel()
        label.text = "BLOCKCHAIN"
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = UIColor.systemPurple
        label.adjustsFontForContentSizeCategory = true
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.secondarySystemGroupedBackground
        selectionStyle = .none
        
        contentView.addSubview(algorithmLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(hashLabel)
        contentView.addSubview(securityBadge)
        contentView.addSubview(legacyBadge)
        contentView.addSubview(checksumBadge)
        contentView.addSubview(blockchainBadge)
        
        // 添加长按手势
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        contentView.addGestureRecognizer(longPressGesture)
        
        algorithmLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(securityBadge.snp.leading).offset(-8).priority(.high)
        }
        
        securityBadge.snp.makeConstraints { make in
            make.centerY.equalTo(algorithmLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        legacyBadge.snp.makeConstraints { make in
            make.centerY.equalTo(algorithmLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        checksumBadge.snp.makeConstraints { make in
            make.centerY.equalTo(algorithmLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        blockchainBadge.snp.makeConstraints { make in
            make.centerY.equalTo(algorithmLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(algorithmLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        hashLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // 添加触觉反馈
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // 执行回调
            onLongPress?()
        }
    }
    
    func configure(with algorithm: HashAlgorithm, hashValue: String?) {
        algorithmLabel.text = algorithm.name
        descriptionLabel.text = algorithm.description
        
        if let hashValue = hashValue {
            hashLabel.text = hashValue
            hashLabel.textColor = UIColor.label
        } else {
            hashLabel.text = "Tap 'Calculate All Hashes' to generate"
            hashLabel.textColor = UIColor.secondaryLabel
        }
        
        // 隐藏所有标识
        securityBadge.isHidden = true
        legacyBadge.isHidden = true
        checksumBadge.isHidden = true
        blockchainBadge.isHidden = true
        
        // 根据算法类型显示相应标识
        let algorithmKey = algorithm.algorithmKey
        
        if algorithmKey == "Keccak-256" {
            blockchainBadge.isHidden = false
        } else if algorithmKey.hasPrefix("CRC") || algorithmKey == "Adler-32" {
            checksumBadge.isHidden = false
        } else if algorithm.isSecure {
            securityBadge.isHidden = false
        } else {
            legacyBadge.isHidden = false
        }
    }
}
