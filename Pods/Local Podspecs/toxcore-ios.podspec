#
# Be sure to run `pod lib lint toxcore-ios.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "toxcore-ios"
  s.version          = "0.1.0"
  s.summary          = "Cocoapods wrapper for toxcore"
  s.homepage         = "https://github.com/dvor/toxcore-ios"
  s.license          = 'GPLv3'
  s.author           = { "Dmytro Vorobiov" => "d@dvor.me" }
  s.source           = {
      :git => "https://github.com/dvor/toxcore-ios.git",
      :tag => s.version.to_s,
      :submodules => true
  }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'toxcore/toxcore/**/*.{c,h}'
  s.public_header_files = 'toxcore/toxcore/**/*.h'
  s.dependency 'libsodium', '~> 1.0.1'
end
