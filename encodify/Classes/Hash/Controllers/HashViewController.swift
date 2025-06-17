//
//  HashViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

/// 重构后的哈希计算控制器
/// 使用模块化设计，支持文本和文件哈希计算
@MainActor
class HashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let hashGroups = HashAlgorithm.allAlgorithms
    private var hashResults: [String: String] = [:]  // [algorithmKey: hashValue]
    private var currentInputType: InputType = .text
    private var currentFileName: String?
    
    private var collectionView: UICollectionView!
    private var dataSourceManager: HashCollectionDataSource!
    private var fileHashManager: FileHashManager!
    private var updateTimer: Timer?
    
    // UI Components
    private var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.textColor = UIColor.label
        textView.setPlaceholder("Enter text here, then tap 'Calculate All Hashes' button to generate hash values...", style: .inputPlaceholder)
        textView.setPlaceholderPadding(0)
        return textView
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
    
    // MARK: - Input Types
    
    enum InputType {
        case text
        case file
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupKeyboardObservers()
        setupCollectionView()
        setupFileHashManager()
        
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNavigationBar() {
        title = "Hash Calculator"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
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
    
    private func setupCollectionView() {
        let layout = HashCollectionLayoutManager.createCompositionalLayout()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.systemGroupedBackground
        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // Register cells
        collectionView.register(InputAreaCell.self, forCellWithReuseIdentifier: "InputAreaCell")
        collectionView.register(CalculateButtonCell.self, forCellWithReuseIdentifier: "CalculateButtonCell")
        collectionView.register(FormatSelectorCell.self, forCellWithReuseIdentifier: "FormatSelectorCell")
        collectionView.register(HashAlgorithmCell.self, forCellWithReuseIdentifier: "HashAlgorithmCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        collectionView.register(SectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SectionFooterView")
        
        // Setup data source
        dataSourceManager = HashCollectionDataSource(collectionView: collectionView)
        dataSourceManager.delegate = self
        dataSourceManager.updateSnapshot(with: hashGroups)
    }
    
    private func setupFileHashManager() {
        fileHashManager = FileHashManager()
        fileHashManager.presentingViewController = self
        fileHashManager.onFileSelected = { [weak self] data, fileName in
            self?.processFileData(data, fileName: fileName)
        }
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
    
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func calculateHashes() {
        view.endEditing(true)
        
        let allResults: [HashResult]
        
        switch currentInputType {
        case .text:
            guard let text = inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                Toast.showError("Please enter text to hash")
                return
            }
            allResults = HashCalculator.calculateHashes(for: text)
            
        case .file:
            guard let inputData = getCurrentInputData() else {
                Toast.showError("Please select a file to hash")
                return
            }
            allResults = HashCalculator.calculateHashes(for: inputData)
        }
        
        // Show loading state
        var config = calculateButton.configuration ?? UIButton.Configuration.filled()
        config.showsActivityIndicator = true
        config.title = "Calculating..."
        calculateButton.configuration = config
        calculateButton.isEnabled = false
        
        // Calculate hashes asynchronously
        Task.detached {
            var results: [String: String] = [:]
            
            for result in allResults {
                results[result.algorithm] = result.hash
            }
            
            await MainActor.run {
                self.hashResults = results
                self.dataSourceManager.reloadHashResults()
                
                // Restore button state
                var config = self.calculateButton.configuration ?? UIButton.Configuration.filled()
                config.showsActivityIndicator = false
                config.title = "Calculate All Hashes"
                self.calculateButton.configuration = config
                self.calculateButton.isEnabled = true
                
                // Success feedback
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.notificationOccurred(.success)
                
                if let fileName = self.currentFileName {
                    Toast.showStatus("Hashes calculated for \(fileName)")
                } else {
                    Toast.showStatus("Hashes calculated successfully")
                }
            }
        }
    }
    
    @objc private func clearAll() {
        view.endEditing(true)
        
        inputTextView.text = ""
        hashResults.removeAll()
        currentInputType = .text
        currentFileName = nil
        updateInputPlaceholder()
        dataSourceManager.reloadHashResults()
        
        Toast.showStatus("Cleared all data")
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    @objc private func pasteText() {
        view.endEditing(true)
        
        guard let text = UIPasteboard.general.string else {
            Toast.showError("No text in clipboard")
            return
        }
        
        currentInputType = .text
        currentFileName = nil
        inputTextView.text = text
        updateInputPlaceholder()
        Toast.showStatus("Text pasted")
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    private func showTypeChanged() {
        dataSourceManager.reloadHashResults()
    }
    
    private func inputTextDidChange() {
        hashResults.removeAll()
        
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.dataSourceManager.reloadHashResults()
            }
        }
    }
    
    // MARK: - File Processing
    
    private func processFileData(_ data: Data, fileName: String) {
        currentInputType = .file
        currentFileName = fileName
        
        // Convert to Base64 for display in text view
        let base64String = data.base64EncodedString()
        let displayText = "File: \(fileName) (\(data.count) bytes)\n\nBase64 representation:\n\(base64String)"
        
        inputTextView.text = displayText
        updateInputPlaceholder()
        
        Toast.showStatus("File loaded: \(fileName)")
        
        // Clear previous results
        hashResults.removeAll()
        dataSourceManager.reloadHashResults()
    }
    
    private func getCurrentInputData() -> Data? {
        switch currentInputType {
        case .text:
            guard let text = inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                return nil
            }
            return text.data(using: .utf8)
            
        case .file:
            // Extract the original file data from the display text
            guard let text = inputTextView.text,
                  text.hasPrefix("File:"),
                  let base64StartRange = text.range(of: "Base64 representation:\n") else {
                return nil
            }
            
            let base64String = String(text[base64StartRange.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            return Data(base64Encoded: base64String)
        }
    }
    
    private func updateInputPlaceholder() {
        switch currentInputType {
        case .text:
            inputTextView.setPlaceholder("Enter text here, then tap 'Calculate All Hashes' button to generate hash values...", style: .inputPlaceholder)
        case .file:
            // Don't show placeholder when displaying file content
            inputTextView.setPlaceholder("", style: .inputPlaceholder)
        }
    }
    
    // MARK: - Keyboard Handling
    
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
    
    // MARK: - Helper Methods
    
    private func formattedHash(_ hash: String) -> String {
        switch showTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            return hash.lowercased()
        case 1:
            return hash.uppercased()
        case 2:
            return hexStringToBase64(hash) ?? hash.lowercased()
        default:
            return hash.lowercased()
        }
    }
    
    private func hexStringToBase64(_ hexString: String) -> String? {
        let cleanHex = hexString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        guard cleanHex.count % 2 == 0 else { return nil }
        
        var data = Data()
        var index = cleanHex.startIndex
        
        while index < cleanHex.endIndex {
            let nextIndex = cleanHex.index(index, offsetBy: 2)
            let byteString = String(cleanHex[index..<nextIndex])
            
            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            data.append(byte)
            
            index = nextIndex
        }
        
        return data.base64EncodedString()
    }
}

// MARK: - UITextViewDelegate

extension HashViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if currentInputType == .text {
            inputTextDidChange()
        }
    }
}

// MARK: - UICollectionViewDelegate

extension HashViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handled by individual cell callbacks
    }
}

// MARK: - HashCollectionDataSourceDelegate

extension HashViewController: HashCollectionDataSourceDelegate {
    
    func configureInputAreaCell(_ cell: InputAreaCell) {
        cell.configure(textView: inputTextView)
        cell.onFullScreenTap = { [weak self] in
            self?.showInputFullScreen()
        }
        cell.onTextChanged = { [weak self] in
            if self?.currentInputType == .text {
                self?.inputTextDidChange()
            }
        }
        cell.onFileTap = { [weak self] in
            self?.fileHashManager.presentFilePicker()
        }
        cell.onImageTap = { [weak self] in
            self?.fileHashManager.presentImagePicker()
        }
    }
    
    func configureCalculateButtonCell(_ cell: CalculateButtonCell) {
        cell.configure(button: calculateButton)
        cell.onButtonTap = { [weak self] in
            self?.calculateHashes()
        }
    }
    
    func configureFormatSelectorCell(_ cell: FormatSelectorCell) {
        cell.configure(segmentedControl: showTypeSegmentedControl)
        cell.onSegmentChanged = { [weak self] in
            self?.showTypeChanged()
        }
    }
    
    func configureHashAlgorithmCell(_ cell: HashAlgorithmCell, sectionIndex: Int, rowIndex: Int) {
        let algorithm = hashGroups[sectionIndex].algorithms[rowIndex]
        let rawHashValue = hashResults[algorithm.algorithmKey]
        let formattedHashValue = rawHashValue != nil ? formattedHash(rawHashValue!) : nil
        
        cell.configure(with: algorithm, hashValue: formattedHashValue)
        cell.onTap = { [weak self] in
            self?.didTapHashCell(algorithm: algorithm)
        }
        cell.onLongPress = { [weak self] in
            self?.didLongPressHashCell(algorithm: algorithm, hashValue: formattedHashValue)
        }
    }
    
    // MARK: - Hash Cell Actions
    
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
        
        let title = currentFileName != nil ? "\(algorithm.name) Hash for \(currentFileName!)" : "\(algorithm.name) Hash Result"
        
        let fullScreenVC = FullScreenTextViewController(
            text: hashValue,
            title: title,
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
    
    private func showInputFullScreen() {
        let title = currentInputType == .file ? "File Content" : "Input Text"
        let placeholder = currentInputType == .file ? "" : "Enter text here, then tap 'Calculate All Hashes' button to generate hash values..."
        
        let fullScreenVC = FullScreenTextViewController(
            text: inputTextView.text ?? "",
            title: title,
            placeholder: placeholder,
            isReadOnly: currentInputType == .file
        )
        
        if currentInputType == .text {
            fullScreenVC.onTextChanged = { [weak self] text in
                self?.inputTextView.text = text
                self?.inputTextDidChange()
            }
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
    
    private func shareText(_ text: String, from source: String) {
        guard !text.isEmpty else {
            Toast.showError("No content to share")
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
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
}
