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
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.becomeFirstResponder()
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Image Decode"
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Decode", style: .plain, target: self, action: #selector(decodeString)),
            UIBarButtonItem(title: "Paste", style: .plain, target: self, action: #selector(pasteString))
        ]
    }
    
    @objc private func pasteString() {
        guard let text = UIPasteboard.general.string, !text.isEmpty else {
            Toast.showStatus("Pasteboard is empty.")
            return
        }
        
        Toast.showStatus("Pasted")
        textView.text = text
    }
    
    @objc private func decodeString() {
        guard let text = textView.text, !text.isEmpty else { return }
        
        guard let data = Data(base64Encoded: text, options: .ignoreUnknownCharacters) else {
            Toast.showStatus("Decode failure.")
            return
        }
        
        guard let image = UIImage(data: data) else {
            Toast.showStatus("Decode failure.")
            return
        }
        
        let imageViewController = ImageViewController(image: image)
        navigationController?.pushViewController(imageViewController, animated: true)
    }
}
