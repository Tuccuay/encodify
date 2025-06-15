//
//  ImageEncodeViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

class ImageEncodeViewController: ThemeAwareViewController {
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        textView.font = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
        textView.adjustsFontForContentSizeCategory = true
        textView.isEditable = false
        textView.backgroundColor = UIColor.encodifyCardBackground
        textView.textColor = UIColor.encodifyPrimaryText
        textView.layer.cornerRadius = 16
        textView.layer.masksToBounds = false
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.isSelectable = true
        textView.dataDetectorTypes = []
        
        // Modern shadow with enhanced depth
        textView.applyThemeAwareShadow(radius: 10, opacity: 0.12, offset: CGSize(width: 0, height: 3))
        
        // Accessibility improvements
        textView.accessibilityLabel = "Encoded image data"
        textView.accessibilityHint = "Base64 encoded image will appear here"
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presentImagePicker()
    }
    
    private func setupUI() {
        title = "Image Encode"
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        // Create modern copy button
        let copyButton = UIBarButtonItem(
            title: "Copy",
            style: .plain,
            target: self,
            action: #selector(copyResult)
        )
        copyButton.tintColor = UIColor.encodifyTintColor
        navigationItem.rightBarButtonItem = copyButton
        
        // Add loading indicator placeholder
        setupLoadingState()
    }
    
    private func setupLoadingState() {
        textView.text = "Loading..."
        textView.textColor = UIColor.encodifySecondaryText
    }
    
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc private func copyResult() {
        guard let text = textView.text, !text.isEmpty, text != "Loading..." else {
            Toast.showError("No content to copy")
            return
        }
        
        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        UIPasteboard.general.string = text
        Toast.showStatus("Copied")
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ImageEncodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        Toast.showStatus("Encoding, please wait.")
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let imageData = image.pngData() else { return }
            let base64String = imageData.base64EncodedString(options: .lineLength64Characters)
            
            DispatchQueue.main.async {
                self?.textView.text = base64String
                self?.textView.textColor = UIColor.encodifyPrimaryText
                
                // Add completion animation
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .allowUserInteraction) {
                    self?.textView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self?.textView.transform = CGAffineTransform.identity
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        Toast.showError("Canceled")
        picker.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
}
