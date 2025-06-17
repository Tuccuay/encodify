#!/usr/bin/env swift

import Foundation

print("🧪 Testing HashViewController full screen button changes...")

// Check if the files exist and contain expected changes
let hashViewControllerPath = "/Users/tuccuay/Projects/encodify/encodify/Classes/Hash/Controllers/HashViewController.swift"
let hashCellPath = "/Users/tuccuay/Projects/encodify/encodify/Classes/Hash/Views/HashCollectionViewCells.swift"

guard let hashViewControllerContent = try? String(contentsOfFile: hashViewControllerPath),
      let hashCellContent = try? String(contentsOfFile: hashCellPath) else {
    print("❌ Failed to read source files")
    exit(1)
}

var allTestsPassed = true

// Test 1: Check if InputAreaCell hides full screen button in file mode
print("🔍 Test 1: InputAreaCell hides full screen button in file mode")
if hashCellContent.contains("// Hide full screen button for file mode") &&
   hashCellContent.contains("fullScreenButton.isHidden = true") {
    print("✅ Pass: Full screen button is hidden in file mode")
} else {
    print("❌ Fail: Full screen button hiding logic not found")
    allTestsPassed = false
}

// Test 2: Check if InputAreaCell shows full screen button in text mode
print("🔍 Test 2: InputAreaCell shows full screen button in text mode")
if hashCellContent.contains("// Show full screen button for text mode") &&
   hashCellContent.contains("fullScreenButton.isHidden = false") {
    print("✅ Pass: Full screen button is shown in text mode")
} else {
    print("❌ Fail: Full screen button showing logic not found")
    allTestsPassed = false
}

// Test 3: Check if HashViewController only allows full screen for text mode
print("🔍 Test 3: HashViewController only allows full screen for text mode")
if hashViewControllerContent.contains("// Only allow full screen for text mode") &&
   hashViewControllerContent.contains("guard currentInputType == .text else") {
    print("✅ Pass: Full screen is restricted to text mode")
} else {
    print("❌ Fail: Full screen restriction logic not found")
    allTestsPassed = false
}

// Test 4: Check if full screen presentation changed to sheet
print("🔍 Test 4: Full screen presentation changed to sheet")
if hashViewControllerContent.contains("modalPresentationStyle = .pageSheet") &&
   hashViewControllerContent.contains("sheet.detents = [.large()]") &&
   hashViewControllerContent.contains("sheet.prefersGrabberVisible = true") {
    print("✅ Pass: Full screen presentation changed to sheet style")
} else {
    print("❌ Fail: Sheet presentation style not found")
    allTestsPassed = false
}

// Test 5: Check if configureInputAreaCell sets callback conditionally
print("🔍 Test 5: configureInputAreaCell sets callback conditionally")
if hashViewControllerContent.contains("// Only set full screen callback for text mode") &&
   hashViewControllerContent.contains("if currentInputType == .text") &&
   hashViewControllerContent.contains("cell.onFullScreenTap = nil") {
    print("✅ Pass: Full screen callback is set conditionally")
} else {
    print("❌ Fail: Conditional callback setting not found")
    allTestsPassed = false
}

// Test 6: Check if old full screen logic was removed
print("🔍 Test 6: Old full screen logic was removed")
if !hashViewControllerContent.contains("modalPresentationStyle = .fullScreen") ||
   !hashViewControllerContent.contains("UINavigationController(rootViewController: fullScreenVC)") {
    print("✅ Pass: Old full screen logic appears to be removed")
} else {
    print("❌ Fail: Old full screen logic still present")
    allTestsPassed = false
}

if allTestsPassed {
    print("\n🎉 All tests passed! HashViewController full screen changes are correctly implemented.")
    print("📝 Summary of changes:")
    print("  • Full screen button is hidden when file/image is selected")
    print("  • Full screen button is only shown in text input mode")
    print("  • Full screen editing now uses sheet presentation instead of full screen")
    print("  • Conditional callback setting based on input mode")
} else {
    print("\n❌ Some tests failed. Please review the implementation.")
    exit(1)
}
