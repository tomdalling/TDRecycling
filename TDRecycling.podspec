Pod::Spec.new do |s|
  s.name             = 'TDRecycling'
  s.version          = '0.0.1'
  s.summary          = "Tom Dalling's personal collection of recycled Objective-C code"
  s.description      = "Tom Dalling's personal collection of recycled Objective-C code"
  s.homepage         = "https://github.com/tomdalling/TDRecycling"
  s.license          = 'MIT'
  s.author           = { 'Tom Dalling' => 'tom' + '@' + 'tomdalling' + '.com' }
  s.source           = { :git => 'https://github.com/tomdalling/TDRecycling.git',
                         :tag => s.version.to_s }

  s.requires_arc = true
  s.default_subspec = 'Foundation'
  s.header_mappings_dir = 'TDRecycling'

  s.subspec 'Foundation' do |s_foundation|
    s_foundation.public_header_files = 'TDRecycling/Foundation/**/*.h'
    s_foundation.source_files = 'TDRecycling/Foundation/**/*.{h,m}'
    s_foundation.frameworks = 'Foundation'
  end

  s.subspec 'OSX' do |s_osx|
    s_osx.platform = :osx
    s_osx.dependency 'TDRecycling/Foundation'

    s_osx.public_header_files = 'TDRecycling/OSX/**/*.h'
    s_osx.source_files = 'TDRecycling/OSX/**/*.{h,m}'
    s_osx.frameworks = 'Cocoa'
  end

#  s.subspec 'iOS' do |s_ios|
#    s_ios.platform = :ios
#    s_ios.dependency = 'TDRecycling/Foundation'
#
#    s_ios.public_header_files = 'iOS/source/**/*.h'
#    s_ios.source_files = 'iOS/source/**/*.{h,m}'
#    s_ios.frameworks = 'UIKit'
#  end

end
