Pod::Spec.new do |s|
  s.name             = "Enumability"
  s.version          = "1.0.0"
  s.summary          = "Enumability, 枚举值与字符串的转换。"
  

  s.homepage         = "https://gitee.com/heyp/BLESample"
  s.license     = {"type" => "MIT", "file" =>"LICENSE"}
  s.authors          = {"Peng" => "13750523250@163.com"}
  s.source           = { :git => "https://github.com/heyupeng/BLESample.git", :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.14'

  s.source_files = 'Enumability/*'

end
