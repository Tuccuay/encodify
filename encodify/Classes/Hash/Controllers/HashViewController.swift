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
    
    // Prevent duplicate file processing
    private var lastProcessedFileName: String?
    private var lastProcessingTime: Date?
    private let duplicateProcessingThreshold: TimeInterval = 1.0 // 1 second
    
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
        calculateHashesOptimized()
    }
    
    // MARK: - Optimized Hash Calculation with Enhanced Error Handling
    
    private func calculateHashesOptimized() {
        view.endEditing(true)

        guard !isCalculating else { return }

        // 预检查系统资源
        guard checkSystemResources() else {
            Toast.showError("Insufficient system resources for hash calculation")
            return
        }

        isCalculating = true
        calculationStartTime = Date()

        showStopButtonTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.showStopButton()
            }
        }

        hashResults.removeAll()
        dataSourceManager.reloadHashResults()

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

        // 智能提示优化
        let fileSizeMB = Double(inputData.count) / (1024 * 1024)
        let statusMessage = getOptimizedStatusMessage(for: fileSizeMB)
        Toast.showStatus(statusMessage)

        // 动态调整更新策略
        let updateStrategy = getUpdateStrategy(for: fileSizeMB)

        Task {
            do {
                var lastUpdateTime = Date()
                var updateCounter = 0

                for try await (progressUpdate, currentResults) in HashCalculator.calculateHashesWithProgress(for: inputData) {
                    let now = Date()
                    let shouldUpdateUI = shouldUpdateUI(
                        lastUpdateTime: lastUpdateTime,
                        updateCounter: updateCounter,
                        strategy: updateStrategy,
                        progressUpdate: progressUpdate
                    )

                    if shouldUpdateUI {
                        await MainActor.run {
                            guard self.isCalculating else { return }

                            self.updateCalculateButtonProgress(progressUpdate.progress)

                            var updatedResults: [String: String] = [:]
                            for result in currentResults {
                                updatedResults[result.algorithm] = result.hash
                            }

                            if updatedResults.count > self.hashResults.count {
                                self.hashResults = updatedResults

                                if self.shouldReloadUI(
                                    newCount: updatedResults.count,
                                    strategy: updateStrategy,
                                    isComplete: progressUpdate.currentAlgorithm == "Complete"
                                ) {
                                    self.dataSourceManager.reloadHashResults()
                                }
                            }
                        }
                        lastUpdateTime = now
                        updateCounter += 1
                    }

                    if progressUpdate.currentAlgorithm == "Complete" {
                        break
                    }
                }

                await MainActor.run {
                    guard self.isCalculating else { return }

                    self.isCalculating = false
                    self.hideStopButton()
                    self.dataSourceManager.reloadHashResults()

                    let feedbackGenerator = UINotificationFeedbackGenerator()
                    feedbackGenerator.notificationOccurred(.success)

                    let resultCount = self.hashResults.count
                    let elapsedTime = Date().timeIntervalSince(self.calculationStartTime ?? Date())
                    
                    // 记录性能指标
                    self.logPerformanceMetrics(startTime: self.calculationStartTime ?? Date(), resultCount: resultCount, fileSizeMB: fileSizeMB)
                    
                    if let fileInfo = self.currentFileInfo {
                        Toast.showSuccess("Computed \(resultCount) hashes for \(fileInfo.fileName) in \(String(format: "%.1f", elapsedTime))s")
                    } else {
                        Toast.showSuccess("Computed \(resultCount) hashes in \(String(format: "%.1f", elapsedTime))s")
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
    
    // MARK: - System Resource Management
    
    private func checkSystemResources() -> Bool {
        let availableMemory = ProcessInfo.processInfo.physicalMemory
        let usedMemory = mach_task_basic_info.getUsedMemory()
        let memoryUsageRatio = Double(usedMemory) / Double(availableMemory)
        
        // 如果内存使用率超过80%，拒绝计算
        if memoryUsageRatio > 0.8 {
            showMemoryWarningAlert()
            return false
        }
        
        return true
    }
    
    private func showMemoryWarningAlert() {
        let alert = UIAlertController(
            title: "Memory Warning",
            message: "System memory usage is high. Close other apps and try again.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Update Strategy Optimization
    
    private struct UpdateStrategy {
        let timeInterval: TimeInterval
        let batchSize: Int
        let updateFrequency: Int
    }
    
    private func getUpdateStrategy(for fileSizeMB: Double) -> UpdateStrategy {
        if fileSizeMB <= 1 {
            return UpdateStrategy(timeInterval: 0.03, batchSize: 2, updateFrequency: 1) // 高频更新
        } else if fileSizeMB <= 10 {
            return UpdateStrategy(timeInterval: 0.05, batchSize: 3, updateFrequency: 2) // 中等更新
        } else if fileSizeMB <= 50 {
            return UpdateStrategy(timeInterval: 0.1, batchSize: 5, updateFrequency: 3) // 低频更新
        } else {
            return UpdateStrategy(timeInterval: 0.2, batchSize: 7, updateFrequency: 5) // 极低频更新
        }
    }
    
    private func shouldUpdateUI(
        lastUpdateTime: Date,
        updateCounter: Int,
        strategy: UpdateStrategy,
        progressUpdate: HashProgressUpdate
    ) -> Bool {
        let now = Date()
        let timeBasedUpdate = now.timeIntervalSince(lastUpdateTime) >= strategy.timeInterval
        let counterBasedUpdate = updateCounter % strategy.updateFrequency == 0
        let isComplete = progressUpdate.currentAlgorithm == "Complete"
        
        return timeBasedUpdate || counterBasedUpdate || isComplete
    }
    
    private func shouldReloadUI(newCount: Int, strategy: UpdateStrategy, isComplete: Bool) -> Bool {
        return newCount % strategy.batchSize == 0 || isComplete
    }
    
    private func getOptimizedStatusMessage(for fileSizeMB: Double) -> String {
        let fileSizeText = ByteCountFormatter.string(fromByteCount: Int64(fileSizeMB * 1024 * 1024), countStyle: .binary)
        
        if fileSizeMB > 100 {
            return "Processing extra-large file (\(fileSizeText)) with conservative strategy..."
        } else if fileSizeMB > 10 {
            return "Processing large file (\(fileSizeText)) with optimized batching..."
        } else if fileSizeMB > 1 {
            return "Processing file (\(fileSizeText)) with parallel acceleration..."
        } else {
            return "Processing \(fileSizeText) with maximum performance..."
        }
    }
    
    @objc private func clearAll() {
        view.endEditing(true)
        
        inputTextView.text = ""
        hashResults.removeAll()
        currentInputType = .text
        currentFileInfo = nil
        
        // Reset duplicate tracking
        lastProcessedFileName = nil
        lastProcessingTime = nil
        
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
        
        // 使用cell的动画方法来显示Stop按钮
        if let cell = getCurrentCalculateButtonCell() {
            cell.showStopButtonWithAnimation()
        } else {
            // 如果cell不可用，fallback到直接显示
            stopButton.isHidden = false
            dataSourceManager.reloadCalculateButtonSection()
        }
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    private func hideStopButton() {
        showStopButtonTimer?.invalidate()
        showStopButtonTimer = nil
        
        // 使用cell的动画方法来隐藏Stop按钮
        if let cell = getCurrentCalculateButtonCell() {
            cell.hideStopButtonWithAnimation()
        } else {
            // 如果cell不可用，fallback到直接隐藏
            stopButton.isHidden = true
            dataSourceManager.reloadCalculateButtonSection()
        }
    }
    
    // 获取当前的CalculateButtonCell
    private func getCurrentCalculateButtonCell() -> CalculateButtonCell? {
        // 查找CalculateButtonSection的indexPath
        let snapshot = dataSourceManager.getCurrentSnapshot()
        
        guard let sectionIndex = snapshot.sectionIdentifiers.firstIndex(of: HashCollectionDataSource.SectionType.calculateButton) else {
            return nil
        }
        
        let indexPath = IndexPath(item: 0, section: sectionIndex)
        return collectionView.cellForItem(at: indexPath) as? CalculateButtonCell
    }
    
    // MARK: - File Processing
    
    private func processFileInfo(_ fileInfo: FileInfo) {
        let now = Date()
        
        // Check for duplicate processing within threshold
        if let lastFileName = lastProcessedFileName,
           let lastTime = lastProcessingTime,
           lastFileName == fileInfo.fileName,
           now.timeIntervalSince(lastTime) < duplicateProcessingThreshold {
            print("Ignoring duplicate file processing: \(fileInfo.fileName)")
            return
        }
        
        // Update tracking variables
        lastProcessedFileName = fileInfo.fileName
        lastProcessingTime = now
        
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
        
        // Reset duplicate tracking
        lastProcessedFileName = nil
        lastProcessingTime = nil
        
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
        
        cell.configure(with: algorithm, hashValue: formattedHashValue, isCalculating: isCalculating)
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

// MARK: - Enhanced Error Handling for Async Operations

extension HashViewController {
    private func handleCalculationError(_ error: Error) {
        isCalculating = false
        hideStopButton()
        
        // 清理可能的内存占用
        hashResults.removeAll()
        
        // 精细的错误分类处理
        let errorMessage: String
        let showRetryOption: Bool
        
        if let nsError = error as NSError? {
            switch nsError.code {
            case NSURLErrorCancelled, -999:
                errorMessage = "Hash calculation was cancelled."
                showRetryOption = false
            case NSURLErrorTimedOut:
                errorMessage = "Calculation timed out. The file may be too large."
                showRetryOption = true
            default:
                if nsError.domain.contains("memory") || nsError.localizedDescription.lowercased().contains("memory") {
                    errorMessage = "Insufficient memory to process this file. Try a smaller file or close other apps."
                    showRetryOption = false
                } else {
                    errorMessage = "Hash calculation failed: \(error.localizedDescription)"
                    showRetryOption = true
                }
            }
        } else {
            errorMessage = "Hash calculation failed: \(error.localizedDescription)"
            showRetryOption = true
        }
        
        if showRetryOption {
            showRetryAlert(message: errorMessage)
        } else {
            Toast.showError(errorMessage)
        }
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
        
        // 刷新UI状态
        dataSourceManager.reloadHashResults()
        updateCalculateButtonState()
    }
    
    private func showRetryAlert(message: String) {
        let alert = UIAlertController(
            title: "Calculation Failed",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            // 稍作延迟后重试
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.calculateHashes()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
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
    
    // MARK: - Performance Monitoring
    
    private func logPerformanceMetrics(startTime: Date, resultCount: Int, fileSizeMB: Double) {
        let elapsedTime = Date().timeIntervalSince(startTime)
        let throughputMBps = fileSizeMB / elapsedTime
        
        print("Hash Performance Metrics:")
        print("- File size: \(String(format: "%.2f", fileSizeMB)) MB")
        print("- Time elapsed: \(String(format: "%.2f", elapsedTime)) seconds")
        print("- Algorithms computed: \(resultCount)")
        print("- Throughput: \(String(format: "%.2f", throughputMBps)) MB/s")
        print("- Average time per algorithm: \(String(format: "%.3f", elapsedTime / Double(resultCount))) seconds")
    }
}

// MARK: - Memory Monitoring Support

private struct mach_task_basic_info {
    static func getUsedMemory() -> UInt64 {
        var info = mach_task_basic_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        return result == KERN_SUCCESS ? UInt64(info.resident_size) : 0
    }
}
