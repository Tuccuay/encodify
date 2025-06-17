//
//  ModernHashViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

/// 现代化的哈希计算控制器
/// 提供分组展示和更好的用户体验
class ModernHashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let hashGroups = HashAlgorithm.allAlgorithms
    private var hashResults: [String: String] = [:]  // [algorithmKey: hashValue]
    
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = UIColor.secondarySystemGroupedBackground
        textView.textColor = UIColor.label
        textView.layer.cornerRadius = 12
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.delegate = self
        textView.applyThemeAwareShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        // 设置占位符
        textView.setPlaceholder("Enter text to calculate hash values...", style: .inputPlaceholder)
        textView.setPlaceholderPadding(16)
        
        return textView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ModernHashCell.self, forCellReuseIdentifier: "HashCell")
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
        
        // 直接将组件添加到主视图
        view.addSubview(topContainerView)
        view.addSubview(tableView)
        
        setContentScrollView(tableView)
        
        topContainerView.addSubview(inputTextView)
        topContainerView.addSubview(calculateButton)
        
        // 设置顶部容器约束 - 添加边距以显示卡片效果
        topContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        calculateButton.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // TableView 占用剩余空间
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        title = "Hash Calculator"
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
}

// MARK: - UITextViewDelegate

extension ModernHashViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 清空之前的结果
        hashResults.removeAll()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ModernHashViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return hashGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashGroups[section].algorithms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HashCell", for: indexPath) as! ModernHashCell
        let algorithm = hashGroups[indexPath.section].algorithms[indexPath.row]
        let hashValue = hashResults[algorithm.algorithmKey]
        
        cell.configure(with: algorithm, hashValue: hashValue)
        
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

extension ModernHashViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let algorithm = hashGroups[indexPath.section].algorithms[indexPath.row]
        
        guard let hashValue = hashResults[algorithm.algorithmKey] else {
            Toast.showError("No hash value available. Please calculate hashes first.")
            return
        }
        
        UIPasteboard.general.string = hashValue
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

class ModernHashCell: UITableViewCell {
    
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
