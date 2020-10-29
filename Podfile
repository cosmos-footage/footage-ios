# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'footage' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for footage
  
  pod 'EFCountingLabel'
  pod 'RealmSwift'
  
end

target 'MainWidgetExtension' do
  use_frameworks!
  
  # Pods for footage
  
  pod 'EFCountingLabel'
  pod 'RealmSwift'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['EXCLUDED_ARCHS[sdk=watchsimulator*]'] = 'arm64'
      config.build_settings['EXCLUDED_ARCHS[sdk=appletvsimulator*]'] = 'arm64'
      
    end
  end
end
