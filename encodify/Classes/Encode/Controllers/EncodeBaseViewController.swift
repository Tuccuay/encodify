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
    private lazy var methodSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Base64", "Unicode", "Morse", "URI"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(methodSegmentedControlChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 4
        textView.delegate = self
        return textView
    }()
    
    private lazy var outputTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 4
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
        
        let storeButtonsView = UIView()
        
        view.addSubview(methodSegmentedControl)
        view.addSubview(inputTextView)
        view.addSubview(storeButtonsView)
        view.addSubview(outputTextView)
        
        methodSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(32)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(methodSegmentedControl.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
        }
        
        storeButtonsView.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(44)
        }
        
        outputTextView.snp.makeConstraints { make in
            make.top.equalTo(storeButtonsView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(inputTextView)
        }
        
        setupButtons(in: storeButtonsView)
    }
    
    private func setupButtons(in containerView: UIView) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 8
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let copyUpButton = createButton(title: "Copy↑", action: #selector(copyUpButtonAction))
        let copyDownButton = createButton(title: "Copy↓", action: #selector(copyDownButtonAction))
        let pasteButton = createButton(title: "Paste", action: #selector(pasteButtonAction))
        let clearButton = createButton(title: "Clear", action: #selector(clearButtonAction))
        let encodeButton = createButton(title: encodeButtonTitle, action: #selector(encodeButtonAction))
        
        [copyUpButton, copyDownButton, pasteButton, clearButton, encodeButton].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToResign))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func methodSegmentedControlChanged() {
        performEncode()
    }
    
    @objc private func copyUpButtonAction() {
        inputTextView.resignFirstResponder()
        
        guard let text = inputTextView.text, !text.isEmpty else {
            Toast.showError("No text in input box.")
            return
        }
        
        UIPasteboard.general.string = text
        Toast.showStatus("Copied")
    }
    
    @objc private func copyDownButtonAction() {
        inputTextView.resignFirstResponder()
        
        guard let text = outputTextView.text, !text.isEmpty else {
            Toast.showError("No text in output box.")
            return
        }
        
        UIPasteboard.general.string = text
        Toast.showStatus("Copied")
    }
    
    @objc private func pasteButtonAction() {
        inputTextView.resignFirstResponder()
        
        guard let pasteText = UIPasteboard.general.string else {
            Toast.showError("No text in clipboard.")
            return
        }
        
        inputTextView.text = pasteText
        Toast.showStatus("Pasted")
        performEncode()
    }
    
    @objc private func clearButtonAction() {
        inputTextView.resignFirstResponder()
        inputTextView.text = ""
        outputTextView.text = ""
        Toast.showStatus("Cleared")
    }
    
    @objc private func encodeButtonAction() {
        performEncode()
    }
    
    @objc private func tapToResign() {
        inputTextView.resignFirstResponder()
    }
    
    // MARK: - Encoding
    @objc private func performEncode() {
        inputTextView.resignFirstResponder()
        
        guard let inputString = inputTextView.text, !inputString.isEmpty else {
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
    func textViewDidChange(_ textView: UITextView) {
        if textView == inputTextView {
            // 延迟触发编码，避免频繁调用
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performEncode), object: nil)
            perform(#selector(performEncode), with: nil, afterDelay: 0.3)
        }
    }
}
