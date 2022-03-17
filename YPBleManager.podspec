Pod::Spec.new do |s|
  s.name             = "YPBleManager"
  s.version          = "1.0.0"
  s.summary          = "对 CBCentralManager 使用的封装"
  

  s.homepage         = "https://gitee.com/heyp/BLESample"
  s.license     = {"type" => "MIT", "file" =>"LICENSE"}
  s.authors          = {"Peng" => "13750523250@163.com"}
  s.source           = { :git => "https://gitee.com/heyp/BLESample.git", :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.14'

  s.source_files = 'YPBleManager/*'
  
  s.dependency 'YPCategory', '~>1.0.0'
end
