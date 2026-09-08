#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'stream_thumbnail'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter plugin for creating a thumbnail from a local video file or from a video URL.'
  s.description      = <<-DESC
A Flutter plugin for creating a thumbnail from a local video file or from a video URL.
                       DESC
  s.homepage         = 'https://github.com/GetStream/stream-core-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Stream' => 'support@getstream.io' }
  s.source           = { :path => '.' }
  s.source_files = 'stream_thumbnail/Sources/stream_thumbnail/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.dependency 'libwebp'

  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.9'
end
