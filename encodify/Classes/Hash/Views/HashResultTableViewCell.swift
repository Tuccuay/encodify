//
//  HashResultTableViewCell.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

class HashResultTableViewCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.encodifyCardBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = false
        
        // Use theme-aware shadow instead of hardcoded black
        view.applyThemeAwareShadow(radius: 8, opacity: 0.08, offset: CGSize(width: 0, height: 2))
        
        return view
    }()
    
    private lazy var algorithmLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.encodifyTintColor
        return label
    }()
    
    private lazy var hashLabel: UILabel = {
        let label = UILabel()
        let baseFont = UIFont.preferredFont(forTextStyle: .callout)
        label.font = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.encodifySecondaryText
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        
        // Enhanced readability for hash strings
        label.adjustsFontSizeToFitWidth = false
        label.allowsDefaultTighteningForTruncation = false
        
        return label
    }()
    
    private lazy var copyIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.encodifyHighlightColor
        view.layer.cornerRadius = 3
        view.alpha = 0
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.encodifyBorderColor.withAlphaComponent(0.3)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(copyIndicatorView)
        containerView.addSubview(algorithmLabel)
        containerView.addSubview(separatorView)
        containerView.addSubview(hashLabel)
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.left.right.equalToSuperview().inset(16)
        }
        
        copyIndicatorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        algorithmLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(20)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(algorithmLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        hashLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityHint = "Double tap to copy hash value"
    }
    
    func configure(algorithm: String, hash: String) {
        algorithmLabel.text = algorithm
        hashLabel.text = hash
        
        // Update accessibility label
        accessibilityLabel = "\(algorithm): \(hash)"
        
        // Add subtle animation for content updates
        UIView.transition(with: containerView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            // Content is updated above
        }, completion: nil)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let animations = {
            if highlighted {
                self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                self.copyIndicatorView.alpha = 0.6
            } else {
                self.containerView.transform = .identity
                self.copyIndicatorView.alpha = 0
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: animations)
        } else {
            animations()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.transform = .identity
        copyIndicatorView.alpha = 0
    }
}
