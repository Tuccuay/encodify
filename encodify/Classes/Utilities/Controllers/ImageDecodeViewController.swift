//
//  ImageDecodeViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

class ImageDecodeViewController: UIViewController {
    
    private lazy var cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = UIColor.secondarySystemGroupedBackground
        textView.textColor = UIColor.label
        textView.layer.cornerRadius = 12
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.applyThemeAwareShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        // Disable horizontal scrolling
        textView.isScrollEnabled = true
        
        // Accessibility improvements
        textView.accessibilityLabel = "Input base64 text"
        textView.accessibilityHint = "Paste or enter base64 encoded image data here"
        
        return textView
    }()
    
    private let placeholderText = "Paste base64 encoded image data here..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlaceholder()
    }
    
    private func setupPlaceholder() {
        textView.setPlaceholder(placeholderText, style: .inputPlaceholder)
        // 手动设置与 UITextView contentInset 一致的 padding
        textView.setPlaceholderPadding(16)
    }
    
    private func setupUI() {
        title = "Image Decode"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // 添加点击手势以收起键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(cardContainerView)
        cardContainerView.addSubview(textView)
        
        cardContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Create modern decode button with enhanced styling
        let decodeButton = UIBarButtonItem(title: "Decode", style: .plain, target: self, action: #selector(decodeString))
        decodeButton.tintColor = UIColor.encodifyTintColor
        
        // Set custom font weight for the button
        decodeButton.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .body)
        ], for: .normal)
        
        // Create modern paste control
        let pasteControl = createPasteControl()
        let pasteBarButtonItem = UIBarButtonItem(customView: pasteControl)
        
        navigationItem.rightBarButtonItems = [decodeButton, pasteBarButtonItem]
        
        // Add entrance animation
        textView.alpha = 0
        textView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.textView.alpha = 1
            self.textView.transform = .identity
        }
    }
    
    private func createPasteControl() -> UIPasteControl {
        let configuration = UIPasteControl.Configuration()
        configuration.displayMode = .labelOnly
        configuration.baseBackgroundColor = UIColor.encodifyTintColor
        configuration.baseForegroundColor = .white
        configuration.cornerRadius = 8
        
        let pasteControl = UIPasteControl(configuration: configuration)
        pasteControl.target = textView
        
        // Add shadow for modern appearance
        pasteControl.applyThemeAwareShadow(radius: 4, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        return pasteControl
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func decodeString() {
        // 收起键盘
        view.endEditing(true)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            Toast.showError("Please enter base64 encoded image data.")
            return
        }
        
        // Show loading state
        let loadingButton = UIBarButtonItem(customView: createLoadingIndicator())
        navigationItem.rightBarButtonItems?[0] = loadingButton
        
        // Perform decoding on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = Data(base64Encoded: text, options: .ignoreUnknownCharacters) else {
                DispatchQueue.main.async {
                    self.resetDecodeButton()
                    Toast.showError("Invalid base64 format. Please check your input.")
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.resetDecodeButton()
                    Toast.showError("Unable to create image from data. Please verify the base64 data represents a valid image.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.resetDecodeButton()
                
                // Success haptic feedback
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
                
                Toast.showStatus("Image decoded successfully!")
                
                let imageViewController = ImageViewController(image: image)
                self.navigationController?.pushViewController(imageViewController, animated: true)
            }
        }
    }
    
    private func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor.encodifyTintColor
        indicator.startAnimating()
        return indicator
    }
    
    private func resetDecodeButton() {
        let decodeButton = UIBarButtonItem(title: "Decode", style: .plain, target: self, action: #selector(decodeString))
        decodeButton.tintColor = UIColor.encodifyTintColor
        decodeButton.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .body)
        ], for: .normal)
        navigationItem.rightBarButtonItems?[0] = decodeButton
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // 在主题变化时更新阴影等主题相关组件
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            textView.applyThemeAwareShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        }
    }
}

// MARK: - UITextViewDelegate
extension ImageDecodeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Placeholder 会自动处理显示/隐藏
    }
    
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
}
