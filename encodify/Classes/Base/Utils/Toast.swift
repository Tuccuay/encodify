//
//  Toast.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class Toast {
    
    // MARK: - Custom Banner Colors
    private static let customColors = AppleMusicBannerColors()
    
    @MainActor
    static func showStatus(_ message: String) {
        let banner = StatusBarNotificationBanner(
            title: message, 
            style: .success,
            colors: customColors
        )
        banner.duration = 1.5
        banner.show()
        
        // Enhanced haptic feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        
        // Add subtle vibration pattern
        let impact = UIImpactFeedbackGenerator(style: .soft)
        impact.impactOccurred()
    }
    
    @MainActor
    static func showError(_ message: String) {
        let banner = StatusBarNotificationBanner(
            title: message, 
            style: .danger,
            colors: customColors
        )
        banner.duration = 2.0
        banner.show()
        
        // Enhanced error feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
        
        // Add double tap for errors
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
    
    @MainActor
    static func showInfo(_ message: String) {
        let banner = StatusBarNotificationBanner(
            title: message, 
            style: .info,
            colors: customColors
        )
        banner.duration = 1.2
        banner.show()
        
        // Subtle info feedback
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }
}

// MARK: - Custom Banner Colors for Modern Style
private final class AppleMusicBannerColors: BannerColorsProtocol, @unchecked Sendable {
    func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .success:
            // Modern gradient-inspired success color
            return UIColor.encodifyTintColor
        case .danger:
            // System red with slight warmth
            return UIColor.encodifyErrorColor
        case .warning:
            // Vibrant warning orange
            return UIColor.encodifyWarningColor
        case .info:
            // Cool blue for information
            return UIColor.encodifySecondaryColor
        case .customView:
            // Neutral background
            return UIColor.encodifyCardBackground
        }
    }
}
