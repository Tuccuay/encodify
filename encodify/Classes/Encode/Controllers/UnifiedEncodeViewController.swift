//
//  UnifiedEncodeViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

/// 统一的编码解码界面控制器
/// 使用现代 iOS 设计，替代 Pager 模式
class UnifiedEncodeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let methods: [EncodeMethod] = [.base64, .unicode, .morse, .uri, .hex, .binary, .rot13]
    private var currentMethodIndex = 0
    private var isEncodeMode = true
    
    // MARK: - UI Components
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear // 改为透明，让主背景显示
        return view
    }()
    
    private lazy var modeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Encode", "Decode"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        
        // 现代样式配置 - 使用卡片样式
        control.selectedSegmentTintColor = UIColor.encodifyTintColor
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.label,
        ], for: .normal)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
        ], for: .selected)
        
        return control
    }()
    
    private lazy var methodCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MethodCell.self, forCellWithReuseIdentifier: MethodCell.identifier)
        
        return collectionView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.applyContentCardStyle()
        return view
    }()
    
    private lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var inputHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var inputHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor.label
        label.text = "Input"
        return label
    }()
    
    private lazy var pasteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        button.addTarget(self, action: #selector(pasteText), for: .touchUpInside)
        return button
    }()
    
    private lazy var inputCopyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.addTarget(self, action: #selector(copyInput), for: .touchUpInside)
        return button
    }()
    
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.setPlaceholder("Enter text to process...", style: .inputPlaceholder)
        textView.setPlaceholderPadding(0)
        return textView
    }()
    
    private lazy var processButton: UIButton = {
        let button = UIButton(type: .system)
        button.applyStyle(.primary, size: .large, title: "Encode")
        button.addTarget(self, action: #selector(processText), for: .touchUpInside)
        return button
    }()
    
    private lazy var outputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private lazy var outputHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var outputHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor.label
        label.text = "Output"
        return label
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.addTarget(self, action: #selector(copyOutput), for: .touchUpInside)
        return button
    }()
    
    private lazy var swapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        button.addTarget(self, action: #selector(swapInputOutput), for: .touchUpInside)
        return button
    }()
    
    private lazy var outputTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        textView.font = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
        textView.backgroundColor = .clear
        textView.textColor = UIColor.secondaryLabel
        return textView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupInitialState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 确保 collectionView 背景保持透明（修复切换 tab 后背景变白的问题）
        methodCollectionView.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 再次确保 collectionView 背景保持透明
        methodCollectionView.backgroundColor = .clear
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // 添加点击手势以收起键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Add header area
        view.addSubview(headerView)
        headerView.addSubview(modeSegmentedControl)
        headerView.addSubview(methodCollectionView)
        
        // Add content area
        view.addSubview(contentView)
        
        // Add input/output areas to content view
        contentView.addSubview(inputContainerView)
        contentView.addSubview(processButton)
        contentView.addSubview(outputContainerView)
        
        // Input area
        inputContainerView.addSubview(inputHeaderView)
        inputContainerView.addSubview(inputTextView)
        
        // Input header with buttons
        inputHeaderView.addSubview(inputHeaderLabel)
        inputHeaderView.addSubview(pasteButton)
        inputHeaderView.addSubview(inputCopyButton)
        
        // Output area
        outputContainerView.addSubview(outputHeaderView)
        outputContainerView.addSubview(outputTextView)
        
        outputHeaderView.addSubview(outputHeaderLabel)
        outputHeaderView.addSubview(copyButton)
        outputHeaderView.addSubview(swapButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let padding = LayoutHelper.Spacing.large.rawValue
        let spacing = LayoutHelper.Spacing.medium.rawValue
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        
        modeSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(32)
        }
        
        methodCollectionView.snp.makeConstraints { make in
            make.top.equalTo(modeSegmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        inputContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        processButton.snp.makeConstraints { make in
            make.top.equalTo(inputContainerView.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.centerY.equalToSuperview()
        }
        
        outputContainerView.snp.makeConstraints { make in
            make.top.equalTo(processButton.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.bottom.equalToSuperview().inset(padding)
            make.height.equalTo(inputContainerView)
        }
        
        inputHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(30)
        }
        
        inputHeaderLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        pasteButton.snp.makeConstraints { make in
            make.trailing.equalTo(inputCopyButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
        
        inputCopyButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(inputHeaderView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(padding)
        }
        
        outputHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(30)
        }
        
        outputHeaderLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        swapButton.snp.makeConstraints { make in
            make.trailing.equalTo(copyButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
        
        copyButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
        
        outputTextView.snp.makeConstraints { make in
            make.top.equalTo(outputHeaderView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(padding)
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Encode & Decode"
        
        // 添加工具栏按钮
        let clearButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(clearAll)
        )
        
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareOutput)
        )
        
        navigationItem.rightBarButtonItems = [shareButton, clearButton]
    }
    
    private func setupInitialState() {
        updateCurrentMethod()
    }
    
    private func updateCurrentMethod() {
        let currentMethod = methods[currentMethodIndex]
        
        configure(with: currentMethod, isEncodeMode: isEncodeMode)
        methodCollectionView.reloadData()
        
        // Scroll to current selected method
        let indexPath = IndexPath(item: currentMethodIndex, section: 0)
        methodCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Configuration
    
    func configure(with method: EncodeMethod, isEncodeMode: Bool) {
        let buttonTitle = isEncodeMode ? "Encode" : "Decode"
        processButton.setTitle(buttonTitle, for: .normal)
        
        let placeholderText = isEncodeMode ? "Enter text to encode..." : "Enter text to decode..."
        inputTextView.setPlaceholder(placeholderText, style: .inputPlaceholder)
        
        // Clear previous results
        outputTextView.text = ""
        
        // Update method-specific placeholder
        updatePlaceholderForMethod(method: method, isEncodeMode: isEncodeMode)
    }
    
    private func updatePlaceholderForMethod(method: EncodeMethod, isEncodeMode: Bool) {
        let methodSpecificText: String
        
        switch method {
        case .base64:
            methodSpecificText = isEncodeMode ? "Enter text to encode as Base64..." : "Enter Base64 text to decode..."
        case .unicode:
            methodSpecificText = isEncodeMode ? "Enter text to encode as Unicode..." : "Enter Unicode text (\\u format) to decode..."
        case .morse:
            methodSpecificText = isEncodeMode ? "Enter text to encode as Morse code..." : "Enter Morse code (dots and dashes) to decode..."
        case .uri:
            methodSpecificText = isEncodeMode ? "Enter text to URL encode..." : "Enter URL encoded text to decode..."
        case .hex:
            methodSpecificText = isEncodeMode ? "Enter text to encode as hexadecimal..." : "Enter hexadecimal text to decode..."
        case .binary:
            methodSpecificText = isEncodeMode ? "Enter text to encode as binary..." : "Enter binary text to decode..."
        case .rot13:
            methodSpecificText = isEncodeMode ? "Enter text to encode with ROT13..." : "Enter ROT13 text to decode..."
        }
        
        inputTextView.setPlaceholder(methodSpecificText, style: .inputPlaceholder)
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func modeChanged() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        isEncodeMode = modeSegmentedControl.selectedSegmentIndex == 0
        updateCurrentMethod()
    }
    
    @objc private func processText() {
        guard let text = inputTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Toast.showError("Please enter text to process")
            return
        }
        
        let currentMethod = methods[currentMethodIndex]
        let result: String
        
        if isEncodeMode {
            result = performEncode(text: text, method: currentMethod)
        } else {
            result = performDecode(text: text, method: currentMethod)
        }
        
        outputTextView.text = result
        
        // Add success feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Auto-scroll to show result
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.outputTextView.scrollToTop()
        }
    }
    
    private func performEncode(text: String, method: EncodeMethod) -> String {
        switch method {
        case .base64:
            return Base64Encoder.encode(text) ?? "Encoding failed"
        case .unicode:
            return UnicodeEncoder.encode(text)
        case .morse:
            return MorseEncoder.encode(text)
        case .uri:
            return URLEncoder.encode(text) ?? "Encoding failed"
        case .hex:
            return HexEncoder.encode(text)
        case .binary:
            return BinaryEncoder.encode(text)
        case .rot13:
            return ROT13Encoder.encode(text)
        }
    }
    
    private func performDecode(text: String, method: EncodeMethod) -> String {
        switch method {
        case .base64:
            return Base64Encoder.decode(text) ?? "Decoding failed"
        case .unicode:
            return UnicodeEncoder.decode(text) ?? "Decoding failed"
        case .morse:
            return MorseEncoder.decode(text)
        case .uri:
            return URLEncoder.decode(text) ?? "Decoding failed"
        case .hex:
            return HexEncoder.decode(text) ?? "Decoding failed"
        case .binary:
            return BinaryEncoder.decode(text) ?? "Decoding failed"
        case .rot13:
            return ROT13Encoder.decode(text)
        }
    }
    
    @objc private func copyOutput() {
        guard !outputTextView.text.isEmpty else {
            Toast.showError("No content to copy")
            return
        }
        
        UIPasteboard.general.string = outputTextView.text
        Toast.showStatus("Copied to clipboard")
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    @objc private func copyInput() {
        guard !inputTextView.text.isEmpty else {
            Toast.showError("No content to copy")
            return
        }
        
        UIPasteboard.general.string = inputTextView.text
        Toast.showStatus("Copied to clipboard")
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    @objc private func pasteText() {
        if let pasteText = UIPasteboard.general.string {
            inputTextView.text = pasteText
            Toast.showStatus("Pasted")
            
            // Auto-process if enabled
            if UserDefaults.standard.bool(forKey: "autoProcess") {
                processText()
            }
        } else {
            Toast.showError("Clipboard is empty")
        }
    }
    
    @objc private func swapInputOutput() {
        let inputText = inputTextView.text ?? ""
        let outputText = outputTextView.text ?? ""
        
        inputTextView.text = outputText
        outputTextView.text = inputText
        
        Toast.showStatus("Content swapped")
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    @objc func clearAll() {
        inputTextView.text = ""
        outputTextView.text = ""
        
        Toast.showStatus("Cleared all content")
    }
    
    @objc func shareOutput() {
        guard !outputTextView.text.isEmpty else {
            Toast.showError("No content to share")
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [outputTextView.text!],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }
}
// MARK: - UITextViewDelegate

extension UnifiedEncodeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Auto-process if enabled and text is not too long
        if UserDefaults.standard.bool(forKey: "autoProcess") && 
           textView.text.count < 10000 && 
           textView.text.count > 0 {
            
            // Debounce the processing
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(processText), object: nil)
            perform(#selector(processText), with: nil, afterDelay: 0.5)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Add subtle scale animation when focused
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.inputContainerView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Reset scale when unfocused
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.inputContainerView.transform = .identity
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension UnifiedEncodeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return methods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MethodCell.identifier, for: indexPath) as! MethodCell
        
        let method = methods[indexPath.item]
        let isSelected = indexPath.item == currentMethodIndex
        
        cell.configure(with: method.displayName, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        currentMethodIndex = indexPath.item
        updateCurrentMethod()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let method = methods[indexPath.item]
        
        // Calculate text width
        let font = UIFont.preferredFont(forTextStyle: .callout)
        let textSize = (method.displayName as NSString).size(withAttributes: [.font: font])
        let width = textSize.width + 32 // Left and right margins
        
        return CGSize(width: max(width, 80), height: 36)
    }
}


