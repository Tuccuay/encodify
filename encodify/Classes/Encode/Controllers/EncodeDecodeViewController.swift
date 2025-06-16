//
//  EncodeDecodeViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

class EncodeDecodeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var currentMethod: EncodeMethod = .base64
    private var isEncodeMode = true
    
    // MARK: - UI Components
    
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
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.delegate = self
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
        setupGestures()
    }
    
    // MARK: - Setup
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        // Add subviews
        view.addSubview(inputContainerView)
        view.addSubview(processButton)
        view.addSubview(outputContainerView)
        
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
        
        inputContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.equalTo(140)
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
        
        processButton.snp.makeConstraints { make in
            make.top.equalTo(inputContainerView.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        outputContainerView.snp.makeConstraints { make in
            make.top.equalTo(processButton.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview().inset(padding)
            make.height.greaterThanOrEqualTo(140)
            make.bottom.lessThanOrEqualToSuperview().inset(padding)
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
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Configuration
    
    func configure(with method: EncodeMethod, isEncodeMode: Bool) {
        self.currentMethod = method
        self.isEncodeMode = isEncodeMode
        
        updateUI()
    }
    
    private func updateUI() {
        let buttonTitle = isEncodeMode ? "Encode" : "Decode"
        processButton.setTitle(buttonTitle, for: .normal)
        
        let placeholderText = isEncodeMode ? "Enter text to encode..." : "Enter text to decode..."
        inputTextView.setPlaceholder(placeholderText, style: .inputPlaceholder)
        
        // Clear previous results
        outputTextView.text = ""
        
        // Update method-specific placeholder
        updatePlaceholderForMethod()
    }
    
    private func updatePlaceholderForMethod() {
        let methodSpecificText: String
        
        switch currentMethod {
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
    
    @objc private func processText() {
        guard let text = inputTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Toast.showError("Please enter text to process")
            return
        }
        
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
    
    @objc private func dismissKeyboard() {
        inputTextView.resignFirstResponder()
    }
}

// MARK: - UITextViewDelegate

extension EncodeDecodeViewController: UITextViewDelegate {
    
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

// MARK: - Helper Types and Extensions

enum EncodeMethod: CaseIterable {
    case base64
    case unicode
    case morse
    case uri
    case hex
    case binary
    case rot13
    
    var displayName: String {
        switch self {
        case .base64: return "Base64"
        case .unicode: return "Unicode"
        case .morse: return "Morse"
        case .uri: return "URI"
        case .hex: return "Hex"
        case .binary: return "Binary"
        case .rot13: return "ROT13"
        }
    }
}



extension UITextView {
    func scrollToTop() {
        setContentOffset(.zero, animated: true)
    }
}
