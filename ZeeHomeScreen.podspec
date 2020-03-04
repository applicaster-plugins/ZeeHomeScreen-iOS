Pod::Spec.new do |s|
  s.name             = "ZeeHomeScreen"
  s.version          = '1.0.0'
  s.summary          = "ZeeHomeScreen"
  s.description      = <<-DESC
                      Zee Home Screen
                       DESC
  s.homepage         = 'https://github.com/applicaster-plugins/ZeeHomeScreen-iOS'
  s.license          = 'CMPS'
  s.author           = { "cmps" => "m.vecselboim@applicaster.com" }
  s.source           = { :git => 'git@github.com:applicaster-plugins/ZeeHomeScreen-iOS.git', :tag => s.version.to_s }
  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.public_header_files = 'ZeeHomeScreen/**/*.h'
  s.source_files = 'ZeeHomeScreen/**/*.{h,m,swift}'

  s.resources = [
    "ZeeHomeScreen/**/*.{png,xib}",
    'ZeeHomeScreen/**/*.plist',
  ]

  s.xcconfig =  {
                  'ENABLE_BITCODE' => 'YES',
                  'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}"/**',
                  'SWIFT_VERSION' => '5.1'
                }

  s.dependency 'ZappPlugins'
  s.dependency 'ApplicasterSDK'

end
