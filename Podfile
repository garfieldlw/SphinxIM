# Uncomment the next line to define a global platform for your project
platform :macos, '13.0'

target 'SphinxIM' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SQLite.swift'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
 target.build_configurations.each do |config|
  if config.build_settings['MACOSX_DEPLOYMENT_TARGET'].to_f < 13.0
    config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '13.0'
   end
  end
 end
end
