# Uncomment this line to define a global platform for your project
platform :ios, '16.6'

target 'encodify' do
  # Using Swift and dynamic frameworks
  use_frameworks!

  # Pods for encodify
  pod 'CryptoSwift'  # Replace CocoaSecurity
  pod 'NotificationBannerSwift'  # Replace CWStatusBarNotification
  pod 'XLPagerTabStrip', '~> 9.0'  # Latest Swift version
  pod 'SnapKit'  # Replace Masonry for Swift
  # FDStackView is not needed in modern iOS
  
#  pod 'LookinServer', :subspecs => ['Swift'], :configurations => ['Debug']


  target 'encodifyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'encodifyUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "16.6"
    end
  end
end
