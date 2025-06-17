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
    private var currentFileInfo: FileInfo?
    private var isCalculating: Bool = false {
        didSet {
            if isCalculating != oldValue {
                updateCalculateButtonState()
            }
        }
    }
    
    private var collectionView: UICollectionView!
    private var dataSourceManager: HashCollectionDataSource!
    private var fileHashManager: FileHashManager!
    private var updateTimer: Timer?
    
    // 停止按钮相关
    private var calculationStartTime: Date?
    private var showStopButtonTimer: Timer?
    
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
    
    private var stopButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Stop"
        config.baseBackgroundColor = UIColor.systemRed
        config.baseForegroundColor = UIColor.white
//        config.cornerStyle = .medium
        config.buttonSize = .small
        config.image = UIImage(systemName: "stop.fill")
        config.imagePadding = 2
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
            return outgoing
        }
        
        let button = UIButton(configuration: config)
        button.isHidden = true
        return button
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
        showStopButtonTimer?.invalidate()
        showStopButtonTimer = nil
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
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
            make.edges.equalToSuperview()
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
        fileHashManager.onFileSelected = { [weak self] fileInfo in
            self?.processFileInfo(fileInfo)
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
        
        // 防止重复计算
        guard !isCalculating else { return }
        
        // 设置计算状态
        isCalculating = true
        calculationStartTime = Date()
        
        // 启动定时器，5秒后显示停止按钮
        showStopButtonTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.showStopButton()
            }
        }
        
        // 清空之前的结果，准备显示新的结果
        hashResults.removeAll()
        dataSourceManager.reloadHashResults()
        
        // 准备输入数据
        let inputData: Data
        switch currentInputType {
        case .text:
            guard let text = inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                Toast.showError("Please enter text to hash")
                isCalculating = false
                return
            }
            guard let data = text.data(using: .utf8) else {
                Toast.showError("Failed to encode text")
                isCalculating = false
                return
            }
            inputData = data
            
        case .file:
            guard let fileInfo = currentFileInfo else {
                Toast.showError("Please select a file to hash")
                isCalculating = false
                return
            }
            inputData = fileInfo.data
        }
        
        // 检查文件大小并显示相应提示
        let fileSizeText = ByteCountFormatter.string(fromByteCount: Int64(inputData.count), countStyle: .binary)
        if inputData.count > 50 * 1024 * 1024 { // 50MB
            Toast.showStatus("Processing large file (\(fileSizeText)) with optimized strategy...")
        } else if inputData.count > 10 * 1024 * 1024 { // 10MB
            Toast.showStatus("Processing file (\(fileSizeText)) with parallel computing...")
        } else {
            Toast.showStatus("Processing \(fileSizeText) with high-speed parallel computing...")
        }
        
        // 在后台线程进行哈希计算，实时更新结果
        Task {
            do {
                var lastUpdateTime = Date()
                let fileSizeMB = Double(inputData.count) / (1024 * 1024)
                
                // 根据文件大小动态调整更新频率
                let updateInterval: TimeInterval = {
                    if fileSizeMB <= 10 { return 0.05 } // 小文件: 50ms更新
                    else if fileSizeMB <= 50 { return 0.1 } // 中等文件: 100ms更新  
                    else { return 0.2 } // 大文件: 200ms更新
                }()
                
                // 使用 AsyncThrowingStream 获取进度更新和结果
                for try await (progressUpdate, currentResults) in HashCalculator.calculateHashesWithProgress(for: inputData) {
                    let now = Date()
                    let shouldUpdateUI = now.timeIntervalSince(lastUpdateTime) >= updateInterval || progressUpdate.currentAlgorithm == "Complete"
                    
                    if shouldUpdateUI {
                        await MainActor.run {
                            // 检查计算状态是否仍然有效
                            guard self.isCalculating else { return }
                            
                            // 更新进度
                            self.updateCalculateButtonProgress(progressUpdate.progress)
                            
                            // 实时更新已完成的哈希结果
                            var updatedResults: [String: String] = [:]
                            for result in currentResults {
                                updatedResults[result.algorithm] = result.hash
                            }
                            
                            // 动态批量更新UI
                            if updatedResults.count > self.hashResults.count {
                                self.hashResults = updatedResults
                                
                                // 根据文件大小调整UI更新策略
                                let shouldReloadUI: Bool = {
                                    if fileSizeMB <= 10 { 
                                        return updatedResults.count % 3 == 0 || progressUpdate.currentAlgorithm == "Complete"
                                    } else if fileSizeMB <= 50 {
                                        return updatedResults.count % 5 == 0 || progressUpdate.currentAlgorithm == "Complete"
                                    } else {
                                        return updatedResults.count % 7 == 0 || progressUpdate.currentAlgorithm == "Complete"
                                    }
                                }()
                                
                                if shouldReloadUI {
                                    self.dataSourceManager.reloadHashResults()
                                }
                            }
                        }
                        lastUpdateTime = now
                    }
                    
                    // 当进度完成时，退出循环
                    if progressUpdate.currentAlgorithm == "Complete" {
                        break
                    }
                }
                
                // 回到主线程完成最终处理
                await MainActor.run {
                    guard self.isCalculating else { return }
                    
                    self.isCalculating = false
                    self.hideStopButton()
                    
                    // 确保最终UI更新
                    self.dataSourceManager.reloadHashResults()
                    
                    // Success feedback
                    let feedbackGenerator = UINotificationFeedbackGenerator()
                    feedbackGenerator.notificationOccurred(.success)
                    
                    let resultCount = self.hashResults.count
                    if let fileInfo = self.currentFileInfo {
                        Toast.showSuccess("Computed \(resultCount) hashes for \(fileInfo.fileName)")
                    } else {
                        Toast.showSuccess("Computed \(resultCount) hashes successfully")
                    }
                }
            } catch {
                await MainActor.run {
                    if error is CancellationError {
                        self.handleCalculationCancellation()
                    } else {
                        self.handleCalculationError(error)
                    }
                }
            }
        }
    }
    
    @objc private func clearAll() {
        view.endEditing(true)
        
        inputTextView.text = ""
        hashResults.removeAll()
        currentInputType = .text
        currentFileInfo = nil
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
        currentFileInfo = nil
        inputTextView.text = text
        updateInputPlaceholder()
        Toast.showStatus("Text pasted")
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    @objc private func stopCalculation() {
        guard isCalculating else { return }
        
        // 取消计算
        HashCalculator.cancelCalculation()
        
        // 立即更新UI状态
        isCalculating = false
        hideStopButton()
        
        Toast.showStatus("Calculation stopped")
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
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
    
    // MARK: - Stop Button Management
    
    private func showStopButton() {
        guard isCalculating else { return }
        
        stopButton.isHidden = false
        dataSourceManager.reloadCalculateButtonSection()
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    private func hideStopButton() {
        showStopButtonTimer?.invalidate()
        showStopButtonTimer = nil
        
        stopButton.isHidden = true
        dataSourceManager.reloadCalculateButtonSection()
    }
    
    // MARK: - File Processing
    
    private func processFileInfo(_ fileInfo: FileInfo) {
        currentInputType = .file
        currentFileInfo = fileInfo
        
        // Clear previous results
        hashResults.removeAll()
        
        // Reload the input area to show file info
        dataSourceManager.reloadHashResults()
        
        Toast.showStatus("File loaded: \(fileInfo.fileName)")
        
        // Auto-calculate hashes for files
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.calculateHashes()
        }
    }
    
    private func clearFileSelection() {
        currentInputType = .text
        currentFileInfo = nil
        hashResults.removeAll()
        
        // Clear text and reset placeholder
        inputTextView.text = ""
        updateInputPlaceholder()
        
        // Reload data to refresh input area
        dataSourceManager.reloadHashResults()
        
        Toast.showStatus("File selection cleared")
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
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
            return currentFileInfo?.data
        }
    }
    
    private func updateInputPlaceholder() {
        switch currentInputType {
        case .text:
            inputTextView.setPlaceholder("Enter text here, then tap 'Calculate All Hashes' button to generate hash values...", style: .inputPlaceholder)
        case .file:
            // File display will be handled by InputAreaCell
            inputTextView.setPlaceholder("", style: .inputPlaceholder)
        }
    }
    
    // MARK: - Button State Management
    
    private func updateCalculateButtonState() {
        var config = calculateButton.configuration ?? UIButton.Configuration.filled()
        
        if isCalculating {
            config.showsActivityIndicator = true
            config.title = "Calculating..."
            calculateButton.alpha = 0.7
            calculateButton.isEnabled = false
        } else {
            config.showsActivityIndicator = false
            config.title = "Calculate All Hashes"
            calculateButton.alpha = 1.0
            calculateButton.isEnabled = true
            hideStopButton()
        }
        
        calculateButton.configuration = config
        
        // 重新加载按钮所在的 cell
        DispatchQueue.main.async { [weak self] in
            self?.dataSourceManager.reloadCalculateButtonSection()
        }
    }
    
    private func updateCalculateButtonProgress(_ progress: Double) {
        guard isCalculating else { return }
        
        var config = calculateButton.configuration ?? UIButton.Configuration.filled()
        config.title = "Calculating... \(Int(progress * 100))%"
        calculateButton.configuration = config
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
        if let fileInfo = currentFileInfo, currentInputType == .file {
            cell.configureWithFile(fileInfo)
        } else {
            cell.configure(textView: inputTextView)
        }
        
        // Only set full screen callback for text mode
        if currentInputType == .text {
            cell.onFullScreenTap = { [weak self] in
                self?.showInputFullScreen()
            }
        } else {
            cell.onFullScreenTap = nil
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
        cell.onClearFile = { [weak self] in
            self?.clearFileSelection()
        }
    }
    
    func configureCalculateButtonCell(_ cell: CalculateButtonCell) {
        cell.configure(button: calculateButton, stopButton: stopButton)
        cell.onButtonTap = { [weak self] in
            self?.calculateHashes()
        }
        cell.onStopButtonTap = { [weak self] in
            self?.stopCalculation()
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
        
        let title = currentFileInfo != nil ? "\(algorithm.name) Hash for \(currentFileInfo!.fileName)" : "\(algorithm.name) Hash Result"
        
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
        // Only allow full screen for text mode
        guard currentInputType == .text else {
            return
        }
        
        let title = "Input Text"
        let placeholder = "Enter text here, then tap 'Calculate All Hashes' button to generate hash values..."
        let displayText = inputTextView.text ?? ""
        
        let fullScreenVC = FullScreenTextViewController(
            text: displayText,
            title: title,
            placeholder: placeholder,
            isReadOnly: false
        )
        
        // 设置文本变更回调
        fullScreenVC.onTextChanged = { [weak self] newText in
            self?.inputTextView.text = newText
            self?.inputTextDidChange()
        }
        
        // 设置分享和复制回调
        fullScreenVC.onShare = { [weak self] text in
            self?.shareText(text, from: "Input Text")
        }
        
        fullScreenVC.onCopy = { [weak self] text in
            self?.copyText(text, from: "Input Text")
        }
        
        fullScreenVC.modalPresentationStyle = .pageSheet
        if let sheet = fullScreenVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(fullScreenVC, animated: true)
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
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

// MARK: - Error Handling for Async Operations

extension HashViewController {
    private func handleCalculationError(_ error: Error) {
        isCalculating = false
        hideStopButton()
        
        // 清理可能的内存占用
        hashResults.removeAll()
        
        // 检查是否是内存相关错误
        let errorMessage: String
        if let nsError = error as NSError? {
            switch nsError.code {
            case -999: // 取消错误
                errorMessage = "Hash calculation was cancelled."
            default:
                errorMessage = "Hash calculation failed: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Hash calculation failed: \(error.localizedDescription)"
        }
        
        Toast.showError(errorMessage)
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
        
        // 刷新UI状态
        dataSourceManager.reloadHashResults()
        updateCalculateButtonState()
    }
    
    private func handleCalculationCancellation() {
        isCalculating = false
        hideStopButton()
        
        Toast.showStatus("Calculation stopped by user")
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()
        
        // 刷新UI状态
        dataSourceManager.reloadHashResults()
        updateCalculateButtonState()
    }
}
