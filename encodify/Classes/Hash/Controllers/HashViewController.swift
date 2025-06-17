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
/// 使用 UICollectionViewCompositionalLayout 提供统一的滚动体验
class HashViewController: UIViewController {
    
    // MARK: - Types
    
    enum SectionType: Int, CaseIterable {
        case formatSelector = 0
        case inputArea = 1
        case calculateButton = 2
        case hashResults = 3
    }
    
    struct Item: Hashable, Sendable {
        let id = UUID()
        let type: ItemType
        
        enum ItemType: Sendable {
            case formatSelector
            case inputArea
            case calculateButton
            case hashGroup(Int) // section index
            case hashAlgorithm(Int, Int) // section index, row index
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    // MARK: - Properties
    
    private let hashGroups = HashAlgorithm.allAlgorithms
    private var hashResults: [String: String] = [:]  // [algorithmKey: hashValue]
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionType, Item>!
    private var isUpdatingDataSource = false
    private var updateTimer: Timer?
    
    // Input components (will be embedded in collection view cells)
    private var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.textColor = UIColor.label
        
        // 设置占位符
        textView.setPlaceholder("Enter text here, then tap 'Calculate All Hashes' button to generate hash values...", style: .inputPlaceholder)
        textView.setPlaceholderPadding(0)
        
        return textView
    }()
    
    private var showTypeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Lowercase", "Uppercase", "Base64"])
        control.selectedSegmentIndex = 0
        
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
    
    private var calculateButton: UIButton = {
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
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupKeyboardObservers()
        setupCollectionView()
        configureDataSource()
        updateDataSource()
        
        // Set up text view delegate
        inputTextView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // 添加点击手势以收起键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupCollectionView() {
        // Create compositional layout
        let layout = createCompositionalLayout()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.systemGroupedBackground
        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // Register cells
        collectionView.register(FormatSelectorCell.self, forCellWithReuseIdentifier: "FormatSelectorCell")
        collectionView.register(InputAreaCell.self, forCellWithReuseIdentifier: "InputAreaCell")
        collectionView.register(CalculateButtonCell.self, forCellWithReuseIdentifier: "CalculateButtonCell")
        collectionView.register(HashAlgorithmCell.self, forCellWithReuseIdentifier: "HashAlgorithmCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        collectionView.register(SectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionFooterView")
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            
            let sectionType = SectionType(rawValue: sectionIndex) ?? .hashResults
            
            switch sectionType {
            case .formatSelector:
                return self.createFormatSelectorSection()
            case .inputArea:
                return self.createInputAreaSection()
            case .calculateButton:
                return self.createCalculateButtonSection()
            case .hashResults:
                return self.createHashResultsSection()
            }
        }
    }
    
    private func createFormatSelectorSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16)
        
        return section
    }
    
    private func createInputAreaSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(140))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(140))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        return section
    }
    
    private func createCalculateButtonSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(70))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(70))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createHashResultsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 8
        
        // Add section header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        // Add section footer for the last group
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        
        section.boundarySupplementaryItems = [header, footer]
        
        return section
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
            self?.collectionView.contentInset.bottom = keyboardHeight - safeAreaBottom
            self?.collectionView.verticalScrollIndicatorInsets.bottom = keyboardHeight - safeAreaBottom
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.collectionView.contentInset.bottom = 0
            self?.collectionView.verticalScrollIndicatorInsets.bottom = 0
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
                    self?.updateDataSource()
                    
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
        updateDataSource()
        
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
        // 格式类型改变时立即重新加载，无需重新计算哈希
        updateDataSource()
    }
    
    private func inputTextDidChange() {
        // 清空之前的结果
        hashResults.removeAll()
        
        // 使用防抖机制：取消之前的定时器并设置新的定时器
        // 只有当用户停止输入 0.3 秒后才更新哈希结果显示
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateHashResultsDisplay()
            }
        }
    }
    
    private func didTapHashCell(algorithm: HashAlgorithm) {
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
    
    private func didLongPressHashCell(algorithm: HashAlgorithm, hashValue: String?) {
        guard let hashValue = hashValue else {
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
        present(navController, animated: true)
    }
    
    @objc private func showInputFullScreen() {
        let fullScreenVC = FullScreenTextViewController(
            text: inputTextView.text ?? "",
            title: "Input Text",
            placeholder: "Enter text here, then tap 'Calculate All Hashes' button to generate hash values...",
            isReadOnly: false
        )
        
        fullScreenVC.onTextChanged = { [weak self] text in
            self?.inputTextView.text = text
            // 使用统一的文本改变处理逻辑
            self?.inputTextDidChange()
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
        inputTextDidChange()
    }
}

// MARK: - UICollectionViewDelegate

extension HashViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handled by individual cell callbacks
    }
}

// MARK: - Collection View Cells

class FormatSelectorCell: UICollectionViewCell {
    var onSegmentChanged: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.secondarySystemGroupedBackground
        layer.cornerRadius = 12
        applyThemeAwareShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 2))
    }
    
    func configure(segmentedControl: UISegmentedControl) {
        // Remove from previous superview if any
        segmentedControl.removeFromSuperview()
        
        contentView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    @objc private func segmentChanged() {
        onSegmentChanged?()
    }
}

class InputAreaCell: UICollectionViewCell {
    var onFullScreenTap: (() -> Void)?
    var onTextChanged: (() -> Void)?
    
    private lazy var headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = UIColor.label
        label.text = "Input Text"
        return label
    }()
    
    private lazy var fullScreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        button.addTarget(self, action: #selector(fullScreenTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.secondarySystemGroupedBackground
        layer.cornerRadius = 12
        applyThemeAwareShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        contentView.addSubview(headerView)
        headerView.addSubview(headerLabel)
        headerView.addSubview(fullScreenButton)
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        fullScreenButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(24)
        }
    }
    
    func configure(textView: UITextView) {
        // Remove from previous superview if any
        textView.removeFromSuperview()
        
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
        
        // Set up text change observation
        NotificationCenter.default.addObserver(
            forName: UITextView.textDidChangeNotification,
            object: textView,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.onTextChanged?()
            }
        }
    }
    
    @objc private func fullScreenTapped() {
        onFullScreenTap?()
    }
}

class CalculateButtonCell: UICollectionViewCell {
    var onButtonTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
    }
    
    func configure(button: UIButton) {
        // Remove from previous superview if any
        button.removeFromSuperview()
        
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        onButtonTap?()
    }
}

class HashAlgorithmCell: UICollectionViewCell {
    var onTap: (() -> Void)?
    var onLongPress: (() -> Void)?
    
    private lazy var algorithmLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor.label
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var hashLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize, weight: .regular)
        label.textColor = UIColor.label
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
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(2)
        }
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.secondarySystemGroupedBackground
        layer.cornerRadius = 12
        applyThemeAwareShadow(radius: 4, opacity: 0.08, offset: CGSize(width: 0, height: 1))
        
        contentView.addSubview(algorithmLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(hashLabel)
        contentView.addSubview(securityBadge)
        contentView.addSubview(legacyBadge)
        contentView.addSubview(checksumBadge)
        contentView.addSubview(blockchainBadge)
        
        // 添加手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
        
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
    
    @objc private func handleTap() {
        onTap?()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
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

class SectionHeaderView: UICollectionReusableView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textColor = UIColor.label
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(title: String, subtitle: String? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
    }
}

class SectionFooterView: UICollectionReusableView {
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    func configureSummary() {
        infoLabel.text = "🔐 Total: 20 hash algorithms supported\n✅ Secure algorithms for modern use\n⚠️ Legacy algorithms for compatibility\n🔗 Blockchain algorithms for crypto\n📊 Checksums for data integrity"
    }
    
    func clear() {
        infoLabel.text = nil
    }
}

// MARK: - UICollectionViewDiffableDataSource

extension HashViewController {
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionType, Item>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            switch item.type {
            case .formatSelector:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FormatSelectorCell", for: indexPath) as! FormatSelectorCell
                cell.configure(segmentedControl: self.showTypeSegmentedControl)
                cell.onSegmentChanged = { [weak self] in
                    self?.showTypeChanged()
                }
                return cell
                
            case .inputArea:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputAreaCell", for: indexPath) as! InputAreaCell
                cell.configure(textView: self.inputTextView)
                cell.onFullScreenTap = { [weak self] in
                    self?.showInputFullScreen()
                }
                cell.onTextChanged = { [weak self] in
                    self?.inputTextDidChange()
                }
                return cell
                
            case .calculateButton:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalculateButtonCell", for: indexPath) as! CalculateButtonCell
                cell.configure(button: self.calculateButton)
                cell.onButtonTap = { [weak self] in
                    self?.calculateHashes()
                }
                return cell
                
            case .hashAlgorithm(let sectionIndex, let rowIndex):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HashAlgorithmCell", for: indexPath) as! HashAlgorithmCell
                let algorithm = self.hashGroups[sectionIndex].algorithms[rowIndex]
                let rawHashValue = self.hashResults[algorithm.algorithmKey]
                let formattedHashValue = rawHashValue != nil ? self.formattedHash(rawHashValue!) : nil
                
                cell.configure(with: algorithm, hashValue: formattedHashValue)
                cell.onTap = { [weak self] in
                    self?.didTapHashCell(algorithm: algorithm)
                }
                cell.onLongPress = { [weak self] in
                    self?.didLongPressHashCell(algorithm: algorithm, hashValue: formattedHashValue)
                }
                return cell
                
            default:
                return UICollectionViewCell()
            }
        }
        
        // Configure supplementary views
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }
            
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
                
                if indexPath.section == SectionType.hashResults.rawValue {
                    // Show a general header for hash results
                    headerView.configure(title: "Hash Results", subtitle: "Tap to copy • Long press to view full screen")
                }
                return headerView
            } else if kind == UICollectionView.elementKindSectionFooter {
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionFooterView", for: indexPath) as! SectionFooterView
                
                // Only show summary footer for hash results section
                if indexPath.section == SectionType.hashResults.rawValue {
                    footerView.configureSummary()
                } else {
                    footerView.clear()
                }
                return footerView
            }
            
            return nil
        }
    }
    
    private func updateDataSource() {
        // Prevent concurrent updates
        guard !isUpdatingDataSource else { return }
        
        // Ensure we're on the main queue
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.updateDataSource()
            }
            return
        }
        
        isUpdatingDataSource = true
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, Item>()
        
        // Add format selector section
        snapshot.appendSections([.formatSelector])
        snapshot.appendItems([Item(type: .formatSelector)], toSection: .formatSelector)
        
        // Add input area section
        snapshot.appendSections([.inputArea])
        snapshot.appendItems([Item(type: .inputArea)], toSection: .inputArea)
        
        // Add calculate button section
        snapshot.appendSections([.calculateButton])
        snapshot.appendItems([Item(type: .calculateButton)], toSection: .calculateButton)
        
        // Add hash results section with all algorithms
        snapshot.appendSections([.hashResults])
        var hashItems: [Item] = []
        
        // 始终显示所有哈希算法，无论是否有计算结果
        for (sectionIndex, group) in hashGroups.enumerated() {
            for (rowIndex, _) in group.algorithms.enumerated() {
                hashItems.append(Item(type: .hashAlgorithm(sectionIndex, rowIndex)))
            }
        }
        
        snapshot.appendItems(hashItems, toSection: .hashResults)
        
        // Apply snapshot with completion handler to reset flag
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.isUpdatingDataSource = false
        }
    }
    
    private func updateHashResultsDisplay() {
        // Prevent concurrent updates
        guard !isUpdatingDataSource else { return }
        
        // Ensure we're on the main queue
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.updateHashResultsDisplay()
            }
            return
        }
        
        isUpdatingDataSource = true
        
        // 获取当前快照
        var snapshot = dataSource.snapshot()
        
        // 如果哈希结果部分已存在，重新加载该部分的所有项目
        if snapshot.sectionIdentifiers.contains(.hashResults) {
            let hashItems = snapshot.itemIdentifiers(inSection: .hashResults)
            snapshot.reloadItems(hashItems)
        }
        
        // 应用快照
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.isUpdatingDataSource = false
        }
    }
}
