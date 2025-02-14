Pod::Spec.new do |s|
  s.name = 'Kommunicate'
  s.version = '7.2.7'
  s.summary = 'Kommunicate iOS SDK for customer support.'
  s.homepage = 'https://github.com/Kommunicate-io/Kommunicate-iOS-SDK'
  s.license = { :type => 'BSD-3-Clause', :file => 'LICENSE' }
  s.author = { 'Mukesh Thawani' => 'mukesh@applozic.com' }
  s.source = { :git => 'https://github.com/Kommunicate-io/Kommunicate-iOS-SDK.git', :tag => s.version }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/Kommunicate/Classes/**/*.{swift}'
  s.resources = 'Sources/Resources/**/*{lproj,storyboard,xib,xcassets,json,strings}'
  s.dependency 'KommunicateChatUI-iOS-SDK' , '1.4.1'
end