//
//  HashCollectionViewCells.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

// MARK: - FormatSelectorCell

@MainActor
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
        backgroundColor = UIColor.clear
        layer.cornerRadius = 0
        // 移除阴影以获得更清爽的外观
    }
    
    func configure(segmentedControl: UISegmentedControl) {
        // Remove from previous superview if any
        segmentedControl.removeFromSuperview()
        
        contentView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    @objc private func segmentChanged() {
        onSegmentChanged?()
    }
}

// MARK: - InputAreaCell

@MainActor
class InputAreaCell: UICollectionViewCell {
    var onFullScreenTap: (() -> Void)?
    var onTextChanged: (() -> Void)?
    var onFileTap: (() -> Void)?
    var onImageTap: (() -> Void)?
    var onClearFile: (() -> Void)?
    
    private var currentFileInfo: FileInfo?
    
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
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var fullScreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        button.addTarget(self, action: #selector(fullScreenTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var fileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc"), for: .normal)
        button.addTarget(self, action: #selector(fileTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var imageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        return button
    }()
    
    // File display components
    private lazy var fileDisplayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.tertiarySystemGroupedBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        view.isHidden = true
        return view
    }()
    
    private lazy var fileIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.systemBlue
        return imageView
    }()
    
    private lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor.label
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var fileSizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    private lazy var fileModificationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = UIColor.tertiaryLabel
        return label
    }()
    
    private lazy var clearFileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor.systemRed
        button.addTarget(self, action: #selector(clearFileTapped), for: .touchUpInside)
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
        headerView.addSubview(buttonsStackView)
        
        buttonsStackView.addArrangedSubview(fileButton)
        buttonsStackView.addArrangedSubview(imageButton)
        buttonsStackView.addArrangedSubview(fullScreenButton)
        
        // Setup file display view
        contentView.addSubview(fileDisplayView)
        fileDisplayView.addSubview(fileIconImageView)
        fileDisplayView.addSubview(fileNameLabel)
        fileDisplayView.addSubview(fileSizeLabel)
        fileDisplayView.addSubview(fileModificationLabel)
        fileDisplayView.addSubview(clearFileButton)
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(96) // 3 buttons * 24 width + 2 spacings * 8
            make.height.equalTo(24)
        }
        
        // File display view constraints
        fileDisplayView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(80)
        }
        
        fileIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        fileNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(fileIconImageView.snp.trailing).offset(12)
            make.trailing.equalTo(clearFileButton.snp.leading).offset(-8)
        }
        
        fileSizeLabel.snp.makeConstraints { make in
            make.top.equalTo(fileNameLabel.snp.bottom).offset(2)
            make.leading.equalTo(fileIconImageView.snp.trailing).offset(12)
            make.trailing.equalTo(clearFileButton.snp.leading).offset(-8)
        }
        
        fileModificationLabel.snp.makeConstraints { make in
            make.top.equalTo(fileSizeLabel.snp.bottom).offset(2)
            make.leading.equalTo(fileIconImageView.snp.trailing).offset(12)
            make.trailing.equalTo(clearFileButton.snp.leading).offset(-8)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        
        clearFileButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }
    }
    
    func configure(textView: UITextView) {
        // Hide file display
        fileDisplayView.isHidden = true
        headerLabel.text = "Input Text"
        
        // Show full screen button for text mode
        fullScreenButton.isHidden = false
        
        // Remove from previous superview if any
        textView.removeFromSuperview()
        
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(80)
        }
        
        // Set up text change observation
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(
            forName: UITextView.textDidChangeNotification,
            object: textView,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.onTextChanged?()
            }
        }
        
        // Show textView
        textView.isHidden = false
    }
    
    func configureWithFile(_ fileInfo: FileInfo) {
        currentFileInfo = fileInfo
        headerLabel.text = "Selected File"
        
        // Hide full screen button for file mode
        fullScreenButton.isHidden = true
        
        // Hide any existing textView
        contentView.subviews.compactMap { $0 as? UITextView }.forEach { textView in
            textView.removeFromSuperview()
        }
        
        // Show file display
        fileDisplayView.isHidden = false
        
        // Configure file display
        fileIconImageView.image = UIImage(systemName: fileInfo.fileType.icon)
        fileNameLabel.text = fileInfo.fileName
        fileSizeLabel.text = fileInfo.formattedFileSize
        fileModificationLabel.text = "Modified: \(fileInfo.formattedModificationDate)"
    }
    
    @objc private func fullScreenTapped() {
        onFullScreenTap?()
    }
    
    @objc private func fileTapped() {
        onFileTap?()
    }
    
    @objc private func imageTapped() {
        onImageTap?()
    }
    
    @objc private func clearFileTapped() {
        currentFileInfo = nil
        fileDisplayView.isHidden = true
        headerLabel.text = "Input Text"
        
        onClearFile?()
    }
}

// MARK: - CalculateButtonCell

@MainActor
class CalculateButtonCell: UICollectionViewCell {
    var onButtonTap: (() -> Void)?
    var onStopButtonTap: (() -> Void)?
    
    private var calculateButton: UIButton?
    private var stopButton: UIButton?
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.alignment = .center
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    func configure(button: UIButton, stopButton: UIButton? = nil) {
        // 清空之前的按钮
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        self.calculateButton = button
        self.stopButton = stopButton
        
        // 移除之前的target
        button.removeTarget(nil, action: nil, for: .allEvents)
        stopButton?.removeTarget(nil, action: nil, for: .allEvents)
        
        // 添加计算按钮
        stackView.addArrangedSubview(button)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // 设置计算按钮约束
        button.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        // 如果有停止按钮，预先添加但隐藏
        if let stopButton = stopButton {
            stackView.addArrangedSubview(stopButton)
            stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
            
            // 设置停止按钮约束
            stopButton.snp.makeConstraints { make in
                make.height.equalTo(50)
            }
            
            // 确保stopButton只占用其内容所需的最小宽度
            stopButton.setContentHuggingPriority(.required, for: .horizontal)
            stopButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            // 设置stopButton的内容边距以减少额外空间
            stopButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            
            // 初始化为隐藏状态
            stopButton.isHidden = true
            stopButton.alpha = 0
            stopButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
    }
    
    // 显示停止按钮的动画方法
    func showStopButtonWithAnimation() {
        guard let stopButton = stopButton, stopButton.isHidden else { return }
        
        // 先显示按钮但保持透明
        stopButton.isHidden = false
        stopButton.alpha = 0
        stopButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        // 执行出现动画
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            stopButton.alpha = 1
            stopButton.transform = .identity
        }
    }
    
    // 添加停止按钮的隐藏动画方法
    func hideStopButtonWithAnimation() {
        guard let stopButton = stopButton, !stopButton.isHidden else { return }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            stopButton.alpha = 0
            stopButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        } completion: { _ in
            stopButton.isHidden = true
            stopButton.transform = .identity
            stopButton.alpha = 1
        }
    }
    
    @objc private func buttonTapped() {
        guard calculateButton?.isEnabled == true else { return }
        onButtonTap?()
    }
    
    @objc private func stopButtonTapped() {
        onStopButtonTap?()
    }
}

// MARK: - HashAlgorithmCell

@MainActor
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
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor.secondaryLabel
        indicator.hidesWhenStopped = true
        indicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // 稍微小一点
        return indicator
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
        contentView.addSubview(loadingIndicator)
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
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(18)
            make.centerY.equalTo(hashLabel)
            make.width.height.equalTo(14)
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
    
    func configure(with algorithm: HashAlgorithm, hashValue: String?, isCalculating: Bool = false) {
        algorithmLabel.text = algorithm.name
        descriptionLabel.text = algorithm.description
        
        if let hashValue = hashValue {
            // 停止loading indicator
            loadingIndicator.stopAnimating()
            
            // 恢复正常间距
            hashLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().inset(16)
            }
            
            // 直接设置hash值，不使用动画
            hashLabel.text = hashValue
            hashLabel.textColor = UIColor.label
            hashLabel.alpha = 1
            hashLabel.transform = .identity
        } else if isCalculating {
            // 为loading indicator留出空间
            hashLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().inset(38)
            }
            
            // 设置计算状态
            hashLabel.text = "Calculating..."
            hashLabel.textColor = UIColor.secondaryLabel
            hashLabel.alpha = 1
            hashLabel.transform = .identity
            loadingIndicator.startAnimating()
        } else {
            // 恢复正常间距
            hashLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().inset(16)
            }
            
            // 设置默认状态
            hashLabel.text = "Tap 'Calculate All Hashes' to generate"
            hashLabel.textColor = UIColor.secondaryLabel
            hashLabel.alpha = 1
            hashLabel.transform = .identity
            loadingIndicator.stopAnimating()
        }
        
        // 先隐藏所有标识
        [securityBadge, legacyBadge, checksumBadge, blockchainBadge].forEach { badge in
            badge.isHidden = true
        }
        
        // 根据算法类型显示相应标识
        let algorithmKey = algorithm.algorithmKey
        
        var targetBadge: UIView?
        if algorithmKey == "Keccak-256" {
            targetBadge = blockchainBadge
        } else if algorithmKey.hasPrefix("CRC") || algorithmKey == "Adler-32" {
            targetBadge = checksumBadge
        } else if algorithm.isSecure {
            targetBadge = securityBadge
        } else {
            targetBadge = legacyBadge
        }
        
        // 直接显示badge，不使用动画
        if let badge = targetBadge {
            badge.isHidden = false
            badge.alpha = 1
            badge.transform = .identity
        }
    }
    
    // 清除hash值的方法（移除动画）
    func clearHashWithAnimation() {
        hashLabel.text = "Tap 'Calculate All Hashes' to generate"
        hashLabel.textColor = UIColor.secondaryLabel
        hashLabel.alpha = 1
        hashLabel.transform = .identity
        loadingIndicator.stopAnimating()
        
        // 恢复正常间距
        hashLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(16)
        }
    }
}

// MARK: - SectionHeaderView

@MainActor
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

// MARK: - SectionFooterView

@MainActor
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
