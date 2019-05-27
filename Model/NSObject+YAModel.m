//
//  NSObject+YAModel.m
//  Aaron
//
//  Created by Chen,Yalun on 2018/12/20.
//  Copyright © 2018 Chen,Yalun. All rights reserved.
//

#import "NSObject+YAModel.h"
#import <objc/runtime.h>
#import <objc/message.h>

// 编码类型
typedef NS_OPTIONS(NSUInteger, YAType) {
    YATypeMask              = 0xFF,
    YATypeUnknown           = 0,
    YATypeBOOL              = 1,
    YATypeNSInteger         = 2,
    YATypeNSUInteger        = 3,
    YATypeCGFloat           = 4,
    YATypeObject            = 5,
    YATypeDate              = 6,
    YATypeClass             = 7,
    YATypeSEL               = 8,
    YATypeArray             = 9,
    YATypeMutableArray      = 10,
    YATypeDictionary        = 11,
    YATypeMutableDictionary = 12,
    YATypeSet               = 13,
    YATypeMutableSet        = 14,
    YATypeString            = 15,
    YATypeMutableString     = 16,
    YATypeData              = 17,
    YATypeNumber            = 18,
    YATypeDecimalNumber     = 19,
};

@implementation NSObject (YAModel)
static NSDictionary *classArrayDict = nil;
+ (instancetype)ya_modelWithDictionary:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:NSDictionary.class]) return nil;
    NSDictionary *propertyList = PropertyList(self);
    id obj = [self new];
    ObjSetWithKeyValueList(obj, propertyList, dict);
    classArrayDict = nil; // Clean memory.
    return obj;
}

+ (instancetype)ya_modelWithJSON:(NSData *)data {
    if (!data || ![data isKindOfClass:NSData.class]) return nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if ([json isKindOfClass:NSDictionary.class]) {
        return [self ya_modelWithDictionary:json];
    }
    return nil;
}

+ (NSArray *)ya_modelArrayWithKeyValuesArray:(NSArray<NSDictionary *> *)dictArray {
    if (!dictArray || ![dictArray isKindOfClass:NSArray.class]) return nil;
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:dictArray.count];
    [dictArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSDictionary.class]) {
            id model = [[self class] ya_modelWithDictionary:obj];
            [tmp addObject:model];
        }
    }];
    return [NSArray arrayWithArray:tmp] ?: nil;
}

// 获取属性列表 key:属性名 value: 属性类型
static NSDictionary *PropertyList(Class cls) {
    if (!cls) return nil;
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    for(int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        NSString *propertyAttr = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSString *type = [propertyAttr substringWithRange:NSMakeRange(1, 1)];
        if ([type isEqualToString:@"@"]) {
            NSArray *components = [propertyAttr componentsSeparatedByString:@"\""];
            if (components.count > 2) {
                Class propCls = NSClassFromString(components[1]);
                if (propCls == NSDate.class) {
                    type = @"1";
                } else if (propCls == NSArray.class) {
                    type = @"2";
                } else if (propCls == NSMutableArray.class) {
                    type = @"3";
                } else if (propCls == NSDictionary.class) {
                    type = @"4";
                } else if (propCls == NSMutableDictionary.class) {
                    type = @"5";
                } else if (propCls == NSSet.class) {
                    type = @"6";
                } else if (propCls == NSMutableSet.class) {
                    type = @"7";
                } else if (propCls == NSString.class) {
                    type = @"8";
                } else if (propCls == NSMutableString.class) {
                    type = @"9";
                } else if (propCls == NSData.class) {
                    type = @"10";
                } else if (propCls == NSNumber.class) {
                    type = @"11";
                } else if (propCls == NSDecimalNumber.class) {
                    type = @"12";
                } else if (propCls == NSObject.class) {
                    type = @"@";
                } else {
                    type = components[1];
                }
            }
        }
        NSNumber *myType = TypeForProperty(type);
        [tempDict setObject:myType forKey:propertyName];
        if (myType.integerValue == 0) {
            [tempDict setObject:type forKey:propertyName];
        }
    }
    free(properties);
    return [NSDictionary dictionaryWithDictionary:tempDict];
}

static NSNumber *TypeForProperty(NSString *type) {
    static NSDictionary *_SELDictionary = nil;;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _SELDictionary = @{
                           @"B": @(YATypeBOOL),
                           @"q": @(YATypeNSInteger),
                           @"Q": @(YATypeNSUInteger),
                           @"d": @(YATypeCGFloat),
                           @"#": @(YATypeClass),
                           @":": @(YATypeSEL),
                           @"@": @(YATypeObject),
                           @"1": @(YATypeDate),
                           @"2": @(YATypeArray),
                           @"3": @(YATypeMutableArray),
                           @"4": @(YATypeDictionary),
                           @"5": @(YATypeMutableDictionary),
                           @"6": @(YATypeSet),
                           @"7": @(YATypeMutableSet),
                           @"8": @(YATypeString),
                           @"9": @(YATypeMutableString),
                           @"10": @(YATypeData),
                           @"11": @(YATypeNumber),
                           @"12": @(YATypeDecimalNumber),
                           };
    });
    return _SELDictionary[type] ?: @(YATypeUnknown);
}

static void ObjSetWithArray(Class cls, NSDictionary *propertyDict, NSArray **keyValueArray) {
    NSMutableArray *tmpArray = [NSMutableArray array];
    [*keyValueArray enumerateObjectsUsingBlock:^(id keyValue, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([keyValue isKindOfClass:NSDictionary.class]) {
            id obj = [cls new];
            ObjSetWithKeyValueList(obj, PropertyList([obj class]), keyValue);
            [tmpArray addObject:obj];
        }
    }];
    *keyValueArray = [NSArray arrayWithArray:tmpArray];
}

static void ObjSetWithKeyValueList(id obj, NSDictionary *propertyDict, NSDictionary *dict) {
    Class cls = [obj class];
    NSDictionary *customPropertyKeyDict = nil;
    if ([cls respondsToSelector:@selector(customPropertyKey)]) {
        customPropertyKeyDict = [cls customPropertyKey];
    }
    
    if ([cls respondsToSelector:@selector(classInArray)] && !classArrayDict) {
        classArrayDict = [cls classInArray];
    }
    
    [propertyDict.allKeys enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL setter = SetterSelectorFromString(name);
        id value = nil;
        if (customPropertyKeyDict[name]) {
            value = customPropertyKeyDict[name];
        } else {
            value = dict[name];
        }
        id propType = propertyDict[name];
        YAType type = [propType integerValue];
        if (value) {
            switch (type & YATypeMask) {
                case YATypeBOOL: {
                    ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)obj, setter, [value boolValue]);
                } break;
                case YATypeNSInteger: {
                    ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)obj, setter, (int64_t)[value longLongValue]);
                } break;
                case YATypeNSUInteger: {
                    ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)obj, setter, (uint64_t)[value unsignedLongLongValue]);
                } break;
                case YATypeCGFloat: {
                    long double d = [value doubleValue];
                    if (isnan(d) || isinf(d)) d = 0;
                    ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)obj, setter, (long double)d);
                } break;
                case YATypeDecimalNumber: {
                    if ([value isKindOfClass:NSNumber.class]) {
                        NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
                        ((void (*)(id, SEL, NSDecimalNumber *))(void *) objc_msgSend)((id)obj, setter, decNum);
                    }
                } break;
                case YATypeClass: {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)obj, setter, NSClassFromString(value));
                } break;
                case YATypeSEL:{
                    ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)obj, setter, NSSelectorFromString(value));
                } break;
                case YATypeDate:{
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, setter, DateFromString(value));
                } break;
                case YATypeArray: {
                    Class cls = classArrayDict[name];
                    if (cls) {
                        ObjSetWithArray(cls, PropertyList(cls), &value);
                    }
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, setter, value);
                } break;
                case YATypeMutableArray: {
                    NSString *clsStr = classArrayDict[name];
                    if (clsStr) {
                        Class cls = NSClassFromString(clsStr);
                        ObjSetWithArray(cls, PropertyList(cls), &value);
                    }
                    value = [NSMutableArray arrayWithArray:value];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, setter, value);
                } break;
                case YATypeSet: {
                    value = [NSSet setWithArray:value];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, setter, value);
                } break;
                case YATypeMutableSet: {
                    value = [NSMutableSet setWithArray:value];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, setter, value);
                } break;
                case YATypeMutableString:
                case YATypeMutableDictionary: {
                    value = [value mutableCopy];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, setter, value);
                } break;
                case YATypeString:
                case YATypeDictionary:
                case YATypeNumber:
                case YATypeUnknown:
                case YATypeObject: {
                    if (type == YATypeUnknown && [propType isKindOfClass:NSString.class]) { // 嵌套模型
                        Class cls = NSClassFromString(propType);
                        if (cls && [value isKindOfClass:NSDictionary.class]) {
                            id obj = [cls new];
                            ObjSetWithKeyValueList(obj, PropertyList(cls), value);
                            value = obj;
                        }
                    }
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, setter, value);
                } break;
                default: break;
            }
        }
    }];
}

// name  ==> setName:
static SEL SetterSelectorFromString(NSString *str) {
    if (!str || str.length <= 0) return nil;
    NSString *result = [NSString stringWithFormat:@"set%@%@:", [str substringToIndex:1].uppercaseString, [str substringFromIndex:1]];
    return NSSelectorFromString(result);
}

// date string ==> data // @"2016-7-16 09:33:22"
static NSDate *DateFromString(NSString *string) {
    typedef NSDate* (^DateParseBlock)(NSString *string);
    static DateParseBlock blocks[20] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // @"2016-07-16 09:33:22" // 19个字符, 对应blocks[19]
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        blocks[19] = ^(NSString *string) {
            return [formatter dateFromString:string];
        };
    });
    if (!string || string.length > 19) return nil;
    DateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
}
@end
