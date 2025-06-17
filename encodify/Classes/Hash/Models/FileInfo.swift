//
//  FileInfo.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import Foundation

/// 文件信息模型
struct FileInfo {
    let data: Data
    let fileName: String
    let fileSize: Int64
    let modificationDate: Date?
    let fileType: FileType
    
    enum FileType {
        case image
        case document
        case unknown
        
        var icon: String {
            switch self {
            case .image:
                return "photo"
            case .document:
                return "doc.text"
            case .unknown:
                return "doc"
            }
        }
    }
    
    var formattedFileSize: String {
        return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    var formattedModificationDate: String {
        guard let modificationDate = modificationDate else {
            return "Unknown"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: modificationDate)
    }
}
