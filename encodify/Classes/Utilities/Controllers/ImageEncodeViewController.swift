//
//  ImageEncodeViewController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

class ImageEncodeViewController: UIViewController {
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isEditable = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presentImagePicker()
    }
    
    private func setupUI() {
        
        title = "Image Encode"
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        let copyButton = UIBarButtonItem(
            title: "Copy",
            style: .plain,
            target: self,
            action: #selector(copyResult)
        )
        copyButton.tintColor = UIColor.encodifyTintColor
        navigationItem.rightBarButtonItem = copyButton
    }
    
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc private func copyResult() {
        guard let text = textView.text, !text.isEmpty else { return }
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
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        Toast.showError("Canceled")
        picker.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
}
