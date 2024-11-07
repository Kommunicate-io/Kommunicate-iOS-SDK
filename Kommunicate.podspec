Pod::Spec.new do |s|
  s.name = 'Kommunicate'
  s.version = '7.2.2'
  s.summary = 'Kommunicate iOS SDK for customer support.'
  s.homepage = 'https://github.com/Kommunicate-io/Kommunicate-iOS-SDK'
  s.license = { :type => 'BSD-3-Clause', :file => 'LICENSE' }
  s.author = { 'Mukesh Thawani' => 'mukesh@applozic.com' }
  s.source = { :git => 'https://github.com/Kommunicate-io/Kommunicate-iOS-SDK.git', :tag => s.version }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.default_subspec = 'Complete'

  s.subspec 'Zendesk' do |with_zendesk|
    with_zendesk.source_files = 'Sources/Kommunicate/Classes/**/*.{swift}'
    with_zendesk.resources = 'Sources/Resources/**/*{lproj,storyboard,xib,xcassets,json,strings}'
    with_zendesk.dependency 'KommunicateChatUI-iOS-SDK/Zendesk', '1.3.6'
  end

  s.subspec 'Complete' do |complete|
    complete.source_files = 'Sources/Kommunicate/Classes/**/*.{swift}'
    complete.resources = 'Sources/Resources/**/*{lproj,storyboard,xib,xcassets,json,strings}'
    complete.dependency 'KommunicateChatUI-iOS-SDK', '1.3.6'
  end
end
