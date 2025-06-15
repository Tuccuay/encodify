//
//  UIColor+Helper.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - Brand Colors
    
    /// Primary brand color with adaptive design - modern pink gradient inspired palette
    static var encodifyTintColor: UIColor {
        return UIColor(named: "PrimaryTint") ?? UIColor.systemPink
    }
    
    /// Secondary accent color - vibrant blue for contrast and accessibility
    static var encodifySecondaryColor: UIColor {
        return UIColor(named: "SecondaryAccent") ?? UIColor.systemBlue
    }
    
    /// Background color for cards and elevated surfaces
    static var encodifyCardBackground: UIColor {
        return UIColor.secondarySystemBackground
    }
    
    /// Background color for buttons - subtle and modern
    static var encodifyButtonBackground: UIColor {
        return UIColor(named: "ButtonBackground") ?? UIColor.systemGray6
    }
    
    /// Subtle border color that adapts to light/dark mode
    static var encodifyBorderColor: UIColor {
        return UIColor.separator
    }
    
    /// Primary text color
    static var encodifyPrimaryText: UIColor {
        return UIColor.label
    }
    
    /// Secondary text color
    static var encodifySecondaryText: UIColor {
        return UIColor.secondaryLabel
    }
    
    // MARK: - Semantic Colors
    
    /// Modern success color with subtle green tones
    static var encodifySuccessColor: UIColor {
        return UIColor.systemGreen
    }
    
    /// Modern warning color with accessible contrast
    static var encodifyWarningColor: UIColor {
        return UIColor.systemOrange
    }
    
    /// Modern error color with proper accessibility
    static var encodifyErrorColor: UIColor {
        return UIColor.systemRed
    }
    
    /// Information color that stands out
    static var encodifyInfoColor: UIColor {
        return encodifySecondaryColor
    }
    
    // MARK: - Background Variations
    
    /// Grouped background for table views and grouped content
    static var encodifyGroupedBackground: UIColor {
        return UIColor.systemGroupedBackground
    }
    
    /// Tertiary background for deeper hierarchy
    static var encodifyTertiaryBackground: UIColor {
        return UIColor.tertiarySystemBackground
    }
    
    // MARK: - Interactive Colors
    
    /// Color for destructive actions with transparency
    static var encodifyDestructiveBackground: UIColor {
        return UIColor.systemRed.withAlphaComponent(0.1)
    }
    
    /// Color for secondary actions
    static var encodifySecondaryBackground: UIColor {
        return encodifySecondaryColor.withAlphaComponent(0.1)
    }
    
    /// Color for highlighted states
    static var encodifyHighlightColor: UIColor {
        return encodifyTintColor.withAlphaComponent(0.2)
    }
}
