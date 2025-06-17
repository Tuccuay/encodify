//
//  FullScreenTextViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

/// 全屏文本编辑/预览控制器
/// 为输入和输出文本提供更大的编辑/预览空间
class FullScreenTextViewController: UIViewController {
    
    // MARK: - Properties
    
    private let initialText: String
    private let isReadOnly: Bool
    private let headerTitle: String
    private let placeholder: String
    
    /// 文本变更回调（仅在编辑模式下使用）
    var onTextChanged: ((String) -> Void)?
    
    /// 分享文本回调
    var onShare: ((String) -> Void)?
    
    /// 复制文本回调
    var onCopy: ((String) -> Void)?
    
    // MARK: - UI Components
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.setText(headerTitle, style: .headline)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor.systemGray2
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var textContainerView: UIView = {
        let view = UIView()
        view.applyContentCardStyle()
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = initialText
        textView.isEditable = !isReadOnly
        textView.isSelectable = true
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.delegate = self
        
        if isReadOnly {
            // 只读模式使用等宽字体便于查看编码结果
            let baseFont = UIFont.preferredFont(forTextStyle: .body)
            textView.font = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
            textView.textColor = UIColor.secondaryLabel
        } else {
            // 编辑模式设置占位符
            if initialText.isEmpty {
                textView.setPlaceholder(placeholder, style: .inputPlaceholder)
            }
        }
        
        return textView
    }()
    
    private lazy var toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.applyStyle(.primary, size: .medium, title: "Done")
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.setText("", style: .caption1)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    init(text: String, title: String, placeholder: String = "Enter text...", isReadOnly: Bool = false) {
        self.initialText = text
        self.isReadOnly = isReadOnly
        self.headerTitle = title
        self.placeholder = placeholder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCharacterCount()
        
        // 如果是编辑模式且没有初始文本，自动弹出键盘
        if !isReadOnly && initialText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.textView.becomeFirstResponder()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 注册键盘通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 移除键盘通知
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // 添加子视图
        view.addSubview(headerView)
        view.addSubview(textContainerView)
        
        // Header
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        headerView.addSubview(actionStackView)
        
        // Action buttons
        actionStackView.addArrangedSubview(shareButton)
        actionStackView.addArrangedSubview(copyButton)
        
        // Text container
        textContainerView.addSubview(textView)
        
        // 只在编辑模式下显示工具栏
        if !isReadOnly {
            view.addSubview(toolbarView)
            toolbarView.addSubview(doneButton)
            toolbarView.addSubview(characterCountLabel)
        }
        
        setupConstraints()
        
        // 添加手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        let padding = LayoutHelper.Spacing.medium.rawValue
        
        // Header
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(padding)
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(padding)
            make.size.equalTo(32)
        }
        
        actionStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(closeButton.snp.leading).offset(-16)
        }
        
        shareButton.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        
        copyButton.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        
        // Text container
        if isReadOnly {
            // 只读模式，文本区域占满剩余空间
            textContainerView.snp.makeConstraints { make in
                make.top.equalTo(headerView.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview().inset(padding)
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(padding)
            }
        } else {
            // 编辑模式，留出工具栏空间
            textContainerView.snp.makeConstraints { make in
                make.top.equalTo(headerView.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview().inset(padding)
                make.bottom.equalTo(toolbarView.snp.top).offset(-8)
            }
            
            // Toolbar
            toolbarView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide)
                make.height.equalTo(100) // 增加工具栏高度以容纳按钮和字符计数标签
            }
            
            doneButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12)
                make.leading.trailing.equalToSuperview().inset(padding)
            }
            
            characterCountLabel.snp.makeConstraints { make in
                make.top.equalTo(doneButton.snp.bottom).offset(12) // 增加间距
                make.leading.trailing.equalToSuperview().inset(padding)
                make.bottom.equalToSuperview().inset(12) // 确保底部有足够边距
            }
        }
        
        // Text view
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(padding)
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
        
        // 如果是编辑模式，通知文本变更
        if !isReadOnly {
            onTextChanged?(textView.text)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func shareTapped() {
        let textToShare = textView.text.isEmpty ? "No content to share" : textView.text!
        onShare?(textToShare)
        
        let activityViewController = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )
        
        // iPad 支持
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        
        present(activityViewController, animated: true)
    }
    
    @objc private func copyTapped() {
        let textToCopy = textView.text.isEmpty ? "" : textView.text!
        onCopy?(textToCopy)
        
        if !textToCopy.isEmpty {
            UIPasteboard.general.string = textToCopy
            Toast.showStatus("Copied to clipboard")
        } else {
            Toast.showError("No content to copy")
        }
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard !isReadOnly else { return }
        
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: duration) {
            self.toolbarView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard !isReadOnly else { return }
        
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: duration) {
            self.toolbarView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateCharacterCount() {
        guard !isReadOnly else { return }
        
        let count = textView.text.count
        let countText = "\(count) characters"
        characterCountLabel.setText(countText, style: .caption1)
    }
}

// MARK: - UITextViewDelegate

extension FullScreenTextViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateCharacterCount()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 添加编辑时的动画效果
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.textContainerView.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // 重置动画效果
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.textContainerView.transform = .identity
        }
    }
}
