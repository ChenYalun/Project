### 关于
字典转模型的简单实践。

### 简介
1. 支持字典转模型
2. 支持字典数组转模型数组
3. 支持模型中嵌套模型
4. 支持模型中嵌套模型数组
5. 支持自定义 属性与字典key的映射

### 使用
#### 模型中支持的类型

```
typedef NS_ENUM(NSUInteger, YASexType) {
    YASexTypeMale,
    YASexTypeFemale,
    YASexTypeOther,
};

@interface YAOne : NSObject
@property YASexType sex;
@property NSNumber *xNSNumber;
@property NSDecimalNumber *xDecimalNumber;
@property BOOL xBOOL;
@property NSInteger xNSInteger;
@property NSUInteger xNSUInteger;
@property CGFloat xCGFloat;
@property NSObject *xNSObject;
@property NSArray *xNSArray;
@property NSMutableArray *xNSMutableArray;
@property NSDictionary *xNSDictionary;
@property NSMutableDictionary *xNSMutableDictionary;
@property NSSet *xNSSet;
@property NSMutableSet *xNSMutableSet;
@property NSString *xNSString;
@property NSMutableString *xNSMutableString;
@property NSData *xNSData;
@property NSDate *xNSDate;
@property Class xClass;
@property SEL xSEL;
@property NSArray <YAOne *> *models;
@property YAOne *one;
@end
```

#### 自定义 属性与字典key的映射

```
+ (NSDictionary *)customPropertyKey {
    return @{@"ID": @"id"};
}
```

#### 容器属性中对应的模型类型

```
+ (NSDictionary *)classInArray {
    return @{@"models": [YAOne class]};
}
```



