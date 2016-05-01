#
#  Be sure to run `pod spec lint HCCoren.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "HCAudioUnit"
  s.version      = "0.0.4"
  s.summary      = "这是一个与声音相关核心库。"
  s.description  = <<-DESC
这是一个特定的核心库。包含了常用录音、及声音滤镜相关的功能。
                   DESC

  s.homepage     = "https://github.com/halfking/HCAudioUnit"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "halfking" => "kimmy.huang@gmail.com" }
  # Or just: s.author    = ""
  # s.authors            = { "" => "" }
  # s.social_media_url   = "http://twitter.com/"

  # s.platform     = :ios
   s.platform     = :ios, "7.0"

#  When using multiple platforms
s.ios.deployment_target = "7.0"
# s.osx.deployment_target = "10.7"
# s.watchos.deployment_target = "2.0"
# s.tvos.deployment_target = "9.0"

s.source       = { :git => "https://github.com/halfking/HCAudioUnit.git", :tag => s.version}

#s.source_files  = "HCAudioUnit/**/*.{h,m,mm,c,cpp}"
#  s.exclude_files = "hccoren/Exclude"
#s.public_header_files = "HCAudioUnit/**/*.h"

# s.resource  = "icon.png"
# s.resources = "Resources/*.png"
# s.preserve_paths = "FilesToSave", "MoreFilesToSave"
#s.frameworks = "UIKit", "Foundation"

s.libraries = "icucore","stdc++"
s.xcconfig = { "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES","ENABLE_BITCODE" => "YES","DEFINES_MODULE" => "YES","HEADER_SEARCH_PATHS" => "$(inherited) $(PROJECT_DIR)/Lib /Users/huangxutao/Documents/Work/HCAudioUnit/Lib","LIBRARY_SEARCH_PATHS" => "$(inherited) $(PROJECT_DIR)/Lib /Users/huangxutao/Documents/Work/HCAudioUnit/Lib" }
s.pod_target_xcconfig = { 'LIBRARY_SEARCH_PATHS' => "$(inherited) /Users/huangxutao/Documents/Work/HCAudioUnit/Lib" }
# s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

s.dependency "HCMinizip", "~> 1.2.6"
s.dependency "hccoren", "~> 0.1.5"

s.subspec 'lame' do |spec|
    spec.source_files = ['Lib/*.h']
    spec.public_header_files = ['Lib/*.h']
    spec.preserve_paths = 'Lib/*.h'
    spec.vendored_libraries = 'Lib/libmp3lame.a', 'Lib/libopencore-amrnb.a','Lib/libopencore-amrwb.a'
    spec.libraries = 'mp3lame', 'opencore-amrnb','opencore-amrwb'
    spec.xcconfig = { 'HEADER_SEARCH_PATHS' => "$(inherited) ${PODS_ROOT}/#{s.name}/Lib/**" }

end
s.subspec 'Amazing' do |spec|
        spec.requires_arc            = true
        spec.source_files = [
            "HCAudioUnit/TheAmazingAudioEngine/**/*.{h,m,mm,c,cpp}",
            "HCAudioUnit/AudioConvert/**/*.{h,m,mm,c,cpp}"
        ]
        spec.public_header_files = [
            "HCAudioUnit/TheAmazingAudioEngine/**/*.h",
            "HCAudioUnit/AudioConvert/**/*.h"
        ]
        #spec.exclude_files = []
        spec.libraries = [
            'icucore',
            'iconv',
            'stdc++',
            'stdc++.6',
        ]
        spec.frameworks = [
            'UIKit',
            'CoreLocation',
            'QuartzCore',
            'OpenGLES',
            'SystemConfiguration',
            'CoreGraphics',
            'Security',
            'IOKit'
        ]
        spec.ios.dependency 'HCAudioUnit/lame'

    end
    s.subspec 'EZAudioDevice' do |spec|
        spec.requires_arc            = false
        spec.source_files = [
            "HCAudioUnit/EZAudio/EZAudioUtilities.{h,m,mm,c,cpp}",
            "HCAudioUnit/EZAudio/EZAudioDevice.{h,m,mm,c,cpp}"
        ]
        spec.public_header_files = [
            "HCAudioUnit/EZAudio/EZAudioUtilities.h",
            "HCAudioUnit/EZAudio/EZAudioDevice.h"
        ]
        #spec.exclude_files = []
        spec.ios.dependency 'HCAudioUnit/lame'
        spec.ios.dependency 'HCAudioUnit/Amazing'
    end
    s.subspec 'Core' do |spec|
        spec.requires_arc            = true
        spec.source_files = [
            "HCAudioUnit/**/*.{h,m,mm,c,cpp}"
        ]
        spec.public_header_files = [
            "HCAudioUnit/**/*.h",
            "HCAudioUnit/**/HCAudioUnit.h"
        ]
        spec.exclude_files = [
            "HCAudioUnit/TheAmazingAudioEngine/**/*.{h,m,mm,c,cpp}",
            "HCAudioUnit/AudioConvert/**/*.{h,m,mm,c,cpp}",
            "HCAudioUnit/EZAudio/EZAudioUtilities.{h,m,mm,c,cpp}",
            "HCAudioUnit/EZAudio/EZAudioDevice.{h,m,mm,c,cpp}",
            "HCAudioUnit/**/HCAudioUnit.h"
        ]
        spec.ios.dependency 'HCAudioUnit/lame'
        spec.ios.dependency 'HCAudioUnit/Amazing'
        spec.ios.dependency 'HCAudioUnit/EZAudioDevice'
    end
end
