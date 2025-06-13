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
        title = "Image Decode"
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        let decodeButton = UIBarButtonItem(title: "Decode", style: .plain, target: self, action: #selector(decodeString))
        decodeButton.tintColor = UIColor.encodifyTintColor
        
        // 创建 UIPasteControl
        let pasteControl = createPasteControl()
        let pasteBarButtonItem = UIBarButtonItem(customView: pasteControl)
        
        navigationItem.rightBarButtonItems = [decodeButton, pasteBarButtonItem]
    }
    
    private func createPasteControl() -> UIPasteControl {
        let configuration = UIPasteControl.Configuration()
        configuration.displayMode = .labelOnly
        configuration.baseBackgroundColor = UIColor.encodifyTintColor
        configuration.baseForegroundColor = .white
        
        let pasteControl = UIPasteControl(configuration: configuration)
        pasteControl.target = textView
        
        return pasteControl
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
