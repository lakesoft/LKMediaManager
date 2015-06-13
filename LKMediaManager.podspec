#
# Be sure to run `pod lib lint LKMediaManager.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LKMediaManager"
  s.version          = "0.1.7"
  s.summary          = "Easy library for handling image/video file"
  s.description      = <<-DESC
  LKMediaManager is useful short lib for image/video.
                       DESC
  s.homepage         = "https://github.com/lakesoft/LKMediaManager"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Hiroshi Hashiguchi" => "hashiguchi@lakesoft.jp" }
  s.source           = { :git => "https://github.com/lakesoft/LKMediaManager.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.3'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.resource_bundles = {
   'LKMediaManager' => ['Pod/Assets/*.*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
