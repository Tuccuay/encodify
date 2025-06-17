//
//  FileHashManager.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

/// 文件哈希计算管理器
@MainActor
class FileHashManager: NSObject {
    
    // MARK: - Types
    
    enum FileType {
        case image
        case document
        case any
    }
    
    // MARK: - Properties
    
    weak var presentingViewController: UIViewController?
    var onFileSelected: ((FileInfo) -> Void)?
    
    // MARK: - Public Methods
    
    func presentFilePicker(for type: FileType = .any) {
        guard let presentingViewController = presentingViewController else { return }
        
        let documentPicker: UIDocumentPickerViewController
        
        switch type {
        case .image:
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image])
        case .document:
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data, .content])
        case .any:
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data, .content, .image])
        }
        
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .formSheet
        
        presentingViewController.present(documentPicker, animated: true)
    }
    
    func presentImagePicker() {
        guard let presentingViewController = presentingViewController else { return }
        
        let alertController = UIAlertController(title: "Select Image", message: "Choose an image source", preferredStyle: .actionSheet)
        
        // Camera option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.presentImagePickerController(sourceType: .camera)
            })
        }
        
        // Photo Library option
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
                self?.presentImagePickerController(sourceType: .photoLibrary)
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = presentingViewController.view
            popover.sourceRect = CGRect(x: presentingViewController.view.bounds.midX, y: presentingViewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        presentingViewController.present(alertController, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func presentImagePickerController(sourceType: UIImagePickerController.SourceType) {
        guard let presentingViewController = presentingViewController else { return }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        
        presentingViewController.present(imagePickerController, animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate

extension FileHashManager: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        // Start accessing security-scoped resource
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            
            // Get file attributes
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? Int64(data.count)
            let modificationDate = attributes[.modificationDate] as? Date
            
            // Determine file type
            let fileType: FileInfo.FileType
            if url.pathExtension.lowercased() == "jpg" || 
               url.pathExtension.lowercased() == "jpeg" ||
               url.pathExtension.lowercased() == "png" ||
               url.pathExtension.lowercased() == "gif" ||
               url.pathExtension.lowercased() == "bmp" ||
               url.pathExtension.lowercased() == "tiff" {
                fileType = .image
            } else if !url.pathExtension.isEmpty {
                fileType = .document
            } else {
                fileType = .unknown
            }
            
            let fileInfo = FileInfo(
                data: data,
                fileName: fileName,
                fileSize: fileSize,
                modificationDate: modificationDate,
                fileType: fileType
            )
            
            onFileSelected?(fileInfo)
        } catch {
            Toast.showError("Failed to read file: \(error.localizedDescription)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // User cancelled file selection
    }
}

// MARK: - UIImagePickerControllerDelegate

extension FileHashManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let image = info[.originalImage] as? UIImage else {
                Toast.showError("Failed to get image")
                return
            }
            
            // Convert image to data (JPEG format)
            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                Toast.showError("Failed to process image")
                return
            }
            
            let fileName = "selected_image.jpg"
            let fileInfo = FileInfo(
                data: imageData,
                fileName: fileName,
                fileSize: Int64(imageData.count),
                modificationDate: Date(),
                fileType: .image
            )
            
            self?.onFileSelected?(fileInfo)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
