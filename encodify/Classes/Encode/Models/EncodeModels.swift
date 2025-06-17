//
//  EncodeModels.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

// MARK: - Encode Method Enum

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

// MARK: - Method Collection View Cell

class MethodCell: UICollectionViewCell {
    static let identifier = "MethodCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
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
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        // Rounded corners and styling
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
    }
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        
        if isSelected {
            contentView.backgroundColor = UIColor.encodifyTintColor
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = UIColor.secondarySystemGroupedBackground
            titleLabel.textColor = UIColor.label
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}

// MARK: - UITextView Extensions

extension UITextView {
    func scrollToTop() {
        setContentOffset(.zero, animated: true)
    }
}
