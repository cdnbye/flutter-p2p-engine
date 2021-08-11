#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'cdnbye'
  s.version          = '0.0.1'
  s.summary          = 'Live/VOD P2P Engine for Flutter.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.dependency 'WebRTCDatachannel', '0.0.1'
  s.dependency 'SwarmCloudSDK', '2.1.1'
  
  s.ios.deployment_target = '10.0'
end

