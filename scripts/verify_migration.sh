#!/bin/bash

# Encodify Swift Migration Verification Script
# 用于验证迁移后的项目状态

echo "🔍 Encodify Swift 迁移验证脚本"
echo "==============================="

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅ 找到文件: $1${NC}"
        return 0
    else
        echo -e "${RED}❌ 缺失文件: $1${NC}"
        return 1
    fi
}

echo
echo "📁 检查核心应用文件..."
check_file "encodify/AppDelegate.swift"
check_file "encodify/SceneDelegate.swift"
check_file "encodify/encodify-Bridging-Header.h"

echo
echo "📱 检查编码模块文件..."
check_file "encodify/Classes/Encode/Controllers/EncodeViewController.swift"
check_file "encodify/Classes/Encode/Controllers/DecodeViewController.swift"
check_file "encodify/Classes/Encode/Controllers/EncodePagerViewController.swift"
check_file "encodify/Classes/Encode/Controllers/EncodeBaseViewController.swift"

echo
echo "🔧 检查编码器文件..."
check_file "encodify/Classes/Encode/Encoders/MorseEncoder.swift"
check_file "encodify/Classes/Encode/Encoders/Base64Encoder.swift"
check_file "encodify/Classes/Encode/Encoders/URLEncoder.swift"
check_file "encodify/Classes/Encode/Encoders/UnicodeEncoder.swift"

echo
echo "🔐 检查哈希模块文件..."
check_file "encodify/Classes/Hash/Controllers/HashViewController.swift"
check_file "encodify/Classes/Hash/Utils/HashCalculator.swift"
check_file "encodify/Classes/Hash/Views/HashResultTableViewCell.swift"

echo
echo "⚙️ 检查工具模块文件..."
check_file "encodify/Classes/Utilities/Controllers/UtilitiesViewController.swift"
check_file "encodify/Classes/Utilities/Controllers/ImageViewController.swift"
check_file "encodify/Classes/Utilities/Controllers/ImageEncodeViewController.swift"
check_file "encodify/Classes/Utilities/Controllers/ImageDecodeViewController.swift"
check_file "encodify/Classes/Utilities/Models/UtilityItem.swift"

echo
echo "🎨 检查基础组件文件..."
check_file "encodify/Classes/Base/Utils/Toast.swift"
check_file "encodify/Classes/Base/Extensions/UIColor+Helper.swift"

echo
echo "🗑️ 检查已删除的文件..."
if [ ! -f "encodify/Classes/Encode/Encoders/XMorseEncoder.swift" ]; then
    echo -e "${GREEN}✅ XMorseEncoder.swift 已正确删除${NC}"
else
    echo -e "${RED}❌ XMorseEncoder.swift 仍然存在${NC}"
fi

echo
echo "📦 检查依赖文件..."
check_file "Podfile"
check_file "Podfile.lock"

echo
echo "📋 Swift文件统计..."
swift_count=$(find encodify/Classes -name "*.swift" | wc -l | xargs)
echo -e "${YELLOW}📊 Swift文件总数: $swift_count${NC}"

echo
echo "🎯 验证完成!"
echo "==============================="

# 检查是否有任何Objective-C文件未备份
echo "🔍 检查未备份的Objective-C文件..."
objc_files=$(find encodify/Classes -name "*.m" -o -name "*.h" | grep -v ".bak" | wc -l | xargs)
if [ "$objc_files" -gt 1 ]; then  # 1 for bridging header
    echo -e "${YELLOW}⚠️  发现 $objc_files 个未备份的Objective-C文件${NC}"
    find encodify/Classes -name "*.m" -o -name "*.h" | grep -v ".bak" | head -5
else
    echo -e "${GREEN}✅ 所有Objective-C文件已正确处理${NC}"
fi

echo
echo "🚀 下一步操作建议:"
echo "1. 在Xcode中打开 encodify.xcworkspace"
echo "2. 将所有Swift文件添加到项目中"
echo "3. 移除旧的Objective-C文件引用"
echo "4. 进行完整的应用测试"
echo
echo "🎉 恭喜！Swift迁移已基本完成！"
