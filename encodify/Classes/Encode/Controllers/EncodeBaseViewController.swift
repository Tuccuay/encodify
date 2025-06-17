//
//  EncodeBaseViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

class EncodeBaseViewController: UIViewController {
    
    // MARK: - Properties
    private let placeholderText = "Enter text to encode..."
    
    private lazy var methodSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Base64", "Unicode", "Morse", "URI"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(methodSegmentedControlChanged), for: .valueChanged)
        
        // Modern styling with enhanced appearance
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
        control.layer.masksToBounds = false
        
        // Enhanced shadow for more depth
        control.applyThemeAwareShadow(radius: 6, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        return control
    }()
    
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = UIColor.encodifyCardBackground
        textView.textColor = UIColor.encodifyPrimaryText
        textView.layer.cornerRadius = 16
        textView.layer.masksToBounds = false
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.delegate = self
        
        // Enhanced shadow with better depth perception
        textView.applyThemeAwareShadow(radius: 10, opacity: 0.12, offset: CGSize(width: 0, height: 3))
        
        // Add placeholder functionality
        textView.setPlaceholder(placeholderText, style: .inputPlaceholder)
        // 手动设置与 UITextView contentInset 一致的 padding
        textView.setPlaceholderPadding(16)
        
        // Accessibility improvements
        textView.accessibilityLabel = "Input text for encoding"
        textView.accessibilityHint = "Enter or paste text here to encode"
        
        return textView
    }()
    
    private lazy var outputTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        textView.font = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = UIColor.encodifyCardBackground
        textView.textColor = UIColor.encodifyPrimaryText
        textView.layer.cornerRadius = 16
        textView.layer.masksToBounds = false
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Enhanced shadow matching input style
        textView.applyThemeAwareShadow(radius: 10, opacity: 0.12, offset: CGSize(width: 0, height: 3))
        
        // Better readability for encoded output
        textView.isSelectable = true
        textView.dataDetectorTypes = []
        
        // Accessibility improvements
        textView.accessibilityLabel = "Encoded output"
        textView.accessibilityHint = "The encoded result will appear here"
        
        return textView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Set background color
        view.backgroundColor = UIColor.systemBackground
        
        let storeButtonsView = UIView()
        
        view.addSubview(methodSegmentedControl)
        view.addSubview(inputTextView)
        view.addSubview(storeButtonsView)
        view.addSubview(outputTextView)
        
        methodSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(methodSegmentedControl.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(120)
        }
        
        storeButtonsView.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        outputTextView.snp.makeConstraints { make in
            make.top.equalTo(storeButtonsView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(inputTextView)
        }
        
        setupButtons(in: storeButtonsView)
    }
    
    private func setupButtons(in containerView: UIView) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 12
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let pasteButton = createButton(title: "Paste", action: #selector(pasteButtonAction), style: .secondary)
        let copyButton = createButton(title: "Copy", action: #selector(copyDownButtonAction), style: .primary)
        let clearButton = createButton(title: "Clear", action: #selector(clearButtonAction), style: .destructive)
        
        [pasteButton, copyButton, clearButton].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    private func createButton(title: String, action: Selector, style: ButtonStyle) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = false
        
        // Configure button based on style with enhanced appearance
        switch style {
        case .primary:
            button.backgroundColor = UIColor.encodifyTintColor
            button.setTitleColor(.white, for: .normal)
            
            // Enhanced shadow for primary button
            button.layer.shadowColor = UIColor.encodifyTintColor.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 8
            button.layer.shadowOpacity = 0.3
            
        case .secondary:
            button.backgroundColor = UIColor.encodifySecondaryColor
            button.setTitleColor(.white, for: .normal)
            
            // Enhanced shadow for secondary button
            button.layer.shadowColor = UIColor.encodifySecondaryColor.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 8
            button.layer.shadowOpacity = 0.25
            
        case .destructive:
            button.backgroundColor = UIColor.encodifyDestructiveBackground
            button.setTitleColor(UIColor.encodifyErrorColor, for: .normal)
            
            // Subtle shadow for destructive button
            button.applyThemeAwareShadow(radius: 6, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        }
        
        // Add haptic feedback
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        
        return button
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Add enhanced visual feedback with spring animation
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .allowUserInteraction, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .allowUserInteraction) {
                sender.transform = CGAffineTransform.identity
            }
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToResign))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func methodSegmentedControlChanged() {
        performEncode()
    }
    
    @objc private func copyDownButtonAction() {
        // 收起键盘
        view.endEditing(true)
        
        guard let text = outputTextView.text, !text.isEmpty else {
            Toast.showError("No text in output box.")
            return
        }
        
        UIPasteboard.general.string = text
        Toast.showStatus("Copied")
    }
    
    @objc private func pasteButtonAction() {
        // 收起键盘
        view.endEditing(true)
        
        guard let pasteText = UIPasteboard.general.string else {
            Toast.showError("No text in clipboard.")
            return
        }
        
        inputTextView.text = pasteText
        Toast.showStatus("Pasted")
        performEncode()
    }
    
    @objc private func clearButtonAction() {
        // 收起键盘
        view.endEditing(true)
        
        inputTextView.text = ""
        outputTextView.text = ""
        Toast.showStatus("Cleared")
    }
    
    @objc private func tapToResign() {
        view.endEditing(true)
    }
    
    // MARK: - Encoding
    @objc private func performEncode() {
        // 收起键盘
        view.endEditing(true)
        
        guard let inputString = inputTextView.text, 
              !inputString.isEmpty else {
            outputTextView.text = ""
            return
        }
        
        var result: String?
        
        switch methodSegmentedControl.selectedSegmentIndex {
        case 0:
            result = encodeWithBase64(inputString)
        case 1:
            result = encodeWithUnicode(inputString)
        case 2:
            result = encodeWithMorse(inputString)
        case 3:
            result = encodeWithURI(inputString)
        default:
            break
        }
        
        outputTextView.text = result ?? ""
    }
    
    // MARK: - Override in subclasses
    func encodeWithBase64(_ inputString: String) -> String? {
        return ""
    }
    
    func encodeWithUnicode(_ inputString: String) -> String? {
        return ""
    }
    
    func encodeWithMorse(_ inputString: String) -> String? {
        return ""
    }
    
    func encodeWithURI(_ inputString: String) -> String? {
        return ""
    }
    
    var encodeButtonTitle: String {
        return "Encode"
    }
}

// MARK: - UITextViewDelegate
extension EncodeBaseViewController: UITextViewDelegate {
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
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == inputTextView {
            // 延迟触发编码，避免频繁调用
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performEncode), object: nil)
            perform(#selector(performEncode), with: nil, afterDelay: 0.3)
        } 
    }
}
