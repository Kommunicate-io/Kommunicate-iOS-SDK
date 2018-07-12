Pod::Spec.new do |s|
  s.name             = 'Kommunicate'
  s.version          = '0.6.0'
  s.summary          = 'Kommunicate iOS SDK for customer support.'
  s.homepage         = 'https://github.com/Kommunicate-io/Kommunicate-iOS-SDK'
  s.license          = { :type => 'BSD-3-Clause', :file => 'LICENSE' }
  s.author           = { 'Mukesh Thawani' => 'mukesh@applozic.com' }
  s.source           = { :git => 'https://github.com/Kommunicate-io/Kommunicate-iOS-SDK.git', :tag => s.version }

  s.social_media_url = 'https://twitter.com/kommunicateio'
  s.ios.deployment_target = '9.0'
  s.source_files = 'Kommunicate/Classes/**/*.{swift}'
  s.resources = 'Kommunicate/Assets/**/*{lproj,storyboard,xib,xcassets,json}'
  s.dependency 'ApplozicSwift', '~> 0.13.0'
end
