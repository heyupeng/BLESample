# Enumability
## 枚举值与字符串的转换

### CocosPods
#### 将`pod 'Enumability', '~>1.0.0'` 加入`Podfile`文件
```
target 'YourApp' do
  ...
  pod 'Enumability', '~>1.0.0'
  ...
end
```
#### 在`Podfile`同级文件夹下运行`pod install`
```
pod install
```

### 使用
#### 以`UIViewContentMode`为例：

```
// 1. 在.h文件声明映射函数
DECLARE_ENUM_VALUE_STRING_TRANSFORMATION(UIViewContentMode);
```

```
// 2. 在.m文件实现映射函数
DEFINE_ENUM_VALUE_STRING_TRANSFORMATION_IMPL(UIViewContentMode,
                                             UIViewContentModeScaleToFill,
                                             UIViewContentModeScaleAspectFit,
                                             UIViewContentModeScaleAspectFill,
                                             UIViewContentModeRedraw,
                                             UIViewContentModeCenter,
                                             UIViewContentModeTop,
                                             UIViewContentModeBottom,
                                             UIViewContentModeLeft,
                                             UIViewContentModeRight,
                                             UIViewContentModeTopLeft,
                                             UIViewContentModeTopRight,
                                             UIViewContentModeBottomLeft,
                                             UIViewContentModeBottomRight
                                             );
```

```
// 3. 调用
    NSString * str; NSInteger value;
    
    value = UIViewContentModeScaleAspectFit;
    str = NSStringFromUIViewContentMode(value);
    NSLog(@"Value %zi => String %@", value, str);
    
    str = @"UIViewContentModeCenter";
    value = UIViewContentModeFromNSString(str);
    NSLog(@"String %@ => Value %zi", str, value);
```

```
// 输出结果
Value 1 => String UIViewContentModeScaleAspectFit
String UIViewContentModeCenter => Value 4
```

### 参考
+ [Easy way to use variables of enum types as string in C?
](https://stackoverflow.com/questions/147267/easy-way-to-use-variables-of-enum-types-as-string-in-c/202511#202511)
+ [OC-Enum-String-Convertible-Example](https://github.com/Yannmm/OC-Enum-String-Convertible-Example)

