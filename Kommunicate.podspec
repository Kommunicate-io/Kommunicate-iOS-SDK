Pod::Spec.new do |s|
  s.name = 'Kommunicate'
  s.version = '5.11.0'
  s.summary = 'Kommunicate iOS SDK for customer support.'
  s.homepage = 'https://github.com/Kommunicate-io/Kommunicate-iOS-SDK'
  s.license = { :type => 'BSD-3-Clause', :file => 'LICENSE' }
  s.author = { 'Mukesh Thawani' => 'mukesh@applozic.com' }
  s.source = { :git => 'https://github.com/Kommunicate-io/Kommunicate-iOS-SDK.git', :tag => s.version }
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.source_files = 'Kommunicate/Classes/**/*.{swift}'
  s.resources = 'Kommunicate/Assets/**/*{lproj,storyboard,xib,xcassets,json,strings}'
  s.dependency 'ApplozicSwift', '~> 5.13.0'
end
