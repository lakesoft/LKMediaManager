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
  s.version          = "1.0.4"
  s.summary          = "Easy library for handling image/video file"
  s.description      = <<-DESC
  LKMediaManager is useful short lib for image/video.
                       DESC
  s.homepage         = "https://github.com/lakesoft/LKMediaManager"
  s.license          = 'MIT'
  s.author           = { "Hiroshi Hashiguchi" => "hashiguchi@lakesoft.jp" }
  s.source           = { :git => "https://github.com/lakesoft/LKMediaManager.git", :tag => s.version.to_s }

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.resource_bundles = {
   'LKMediaManager' => ['Pod/Assets/*.*']
  }

end
