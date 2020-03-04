Pod::Spec.new do |s|
  s.name             = "ParentLockScreenPlugin"
  s.version          = '4.0.0'
  s.summary          = "ParentLockScreenPlugin"
  s.description      = <<-DESC
                        plugin that provides a parent Validation before entering a specific area.
                       DESC
  s.homepage         = "https://github.com/applicaster-plugins/ParentLockScreenPlugin-iOS"
  s.license          = 'CMPS'
  s.author           = { "cmps" => "r.kedarya@applicaster.com" }
  s.source           = { :git => "git@github.com:applicaster-plugins/ParentLockScreenPlugin-iOS.git", :tag => s.version.to_s }
  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.public_header_files = 'ParentLockScreenPlugin-iOS/**/*.h'
  s.source_files = 'ParentLockScreenPlugin-iOS/**/*.{h,m,swift}'


  s.resources = [
    "Resources/*.{png,xib}"
  ]

  s.xcconfig =  {
                  'ENABLE_BITCODE' => 'YES',
                  'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}"/**',
                  'SWIFT_VERSION' => '5.1'
                }

  s.dependency 'ZappPlugins'
  s.dependency 'ApplicasterSDK'
end
