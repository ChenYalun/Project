//
//  KVO.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/5/21.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YAKeyValueProperty.h"
#import <objc/runtime.h>
#define ClassPrefixCStr "YAKVONotifying_" // 新类的前缀
#define ClassPrefix     @ ClassPrefixCStr
#define OBSERVATION_INFO_KEY(object) ((void *)(~(NSUInteger)(object)))
static NSMutableDictionary *YAKeyValueChangeDictionary = nil;



/// 一些私有方法和属性
@interface NSObject(YAKVOPrivate)
@end
@implementation NSObject(YAKVOPrivate)
- (BOOL)ya_isKVOClass {
    return NO;
}

- (void)ya_changeValueForKey:(NSString *)key usingBlock:(void (^)(void))block {
    [self ya_willChangeValueForKey:key];
    if (block) block();
    [self ya_didChangeValueForKey:key];
}
@end



/// 包装keyPath和originalClass
@interface YAKeyValueProperty : NSObject
@property (nonatomic, assign) Class isaForAutonotifying;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, assign) Class originalClass;
- (instancetype)initWithOriginalClass:(Class)originalClass keyPath:(NSString *)keyPath;
@end
@implementation YAKeyValueProperty
- (instancetype)initWithOriginalClass:(Class)originalClass
                              keyPath:(NSString *)keyPath {
    if (self = [super init]) {
        _originalClass = originalClass;
        _keyPath = keyPath;
    }
    return self;
}

- (Class)isaForAutonotifying {
    // 构造新的子类名
    const char *originalClassName = class_getName(_originalClass);
    size_t size = strlen(originalClassName) + 16;
    char *newClassName = (char *)malloc(size);
    
    strlcpy(newClassName, ClassPrefixCStr, size);
    strlcat(newClassName, originalClassName, size);
    
    // 创建子类
    Class newSubClass = objc_allocateClassPair(_originalClass, newClassName, 0);
    objc_registerClassPair(newSubClass);
    free(newClassName);
    
    // Setter方法替换
    NSString *uppercase= [[_keyPath substringToIndex:1] uppercaseString];
    NSString *last = [_keyPath substringFromIndex:1];
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", uppercase, last];
    SEL sel = NSSelectorFromString(setter);
    Method method = class_getInstanceMethod(newSubClass, sel);
    if (method) {
        const char *typeEncoding = method_getTypeEncoding(method);
        class_replaceMethod(newSubClass, sel, (IMP)YASetValueAndNotifyForKey, typeEncoding);
    } else {
        [[NSException exceptionWithName:@"缺少参数" reason:@"没有实现Setter方法" userInfo:nil] raise];
    }
    
    // class方法替换、ya_isKVOClass方法替换
    YAKVONotifyingSetMethodImplementation(newSubClass, @selector(ya_isKVOClass), (IMP)YAKVOIsAutonotifying);
    YAKVONotifyingSetMethodImplementation(newSubClass, @selector(class), (IMP)YAKVOClass);
    return newSubClass;
}

// 对应originalClass的ya_isKVOClass方法
BOOL YAKVOIsAutonotifying(id object, SEL sel) {
    return YES;
}

// 对应originalClass的class方法
Class YAKVOClass(id object, SEL sel) {
    // 新的class: NSKVONotifying_XXXX
    Class currentClass = object_getClass(object);
    if ([object ya_isKVOClass]) {
        NSString *clsStr = [NSStringFromClass(currentClass) stringByReplacingOccurrencesOfString:ClassPrefix withString:@""];
        return NSClassFromString(clsStr);
    }
    return currentClass;
}

// 对应originalClass的setter方法
void YASetValueAndNotifyForKey(id obj, SEL sel, id value, IMP imp) {
    NSString *key = [[NSStringFromSelector(sel) substringFromIndex:3] lowercaseString];
    key = [key substringToIndex:key.length - 1];
    [obj ya_changeValueForKey:key usingBlock:^{
        Class cls = [obj class];
        // 调用父类的setter方法
        IMP superImp = class_getMethodImplementation(cls, sel);
        ((void (*)(id ,SEL , id))superImp)(obj, sel, value);
    }];
}

// 对某个class添加实例方法
void YAKVONotifyingSetMethodImplementation(Class cls, SEL sel, IMP imp) {
    Method originMethod = class_getInstanceMethod(cls, sel);
    const char *encoding = NULL;
    if (originMethod) {
        encoding = method_getTypeEncoding(originMethod);
        class_addMethod(cls, sel, imp, encoding);
    }
}
@end



/// 包装property、observer、context、options
@interface YAKeyValueObservance : NSObject
@property (nonatomic, weak) YAKeyValueProperty *property;
@property (nonatomic, weak) id observer;
@property (nonatomic, assign) void *context;
@property (nonatomic, assign) int options;
- (instancetype)initWithObserver:(id)observer property:(YAKeyValueProperty *)property options:(int)options context:(void *)context;
@end
@implementation YAKeyValueObservance
- (instancetype)initWithObserver:(id)observer
                        property:(YAKeyValueProperty *)property
                         options:(int)options
                         context:(void *)context {
    if (self = [super init]) {
        _observer = observer;
        _property = property;
        _options = options;
        _context = context;
    }
    return self;
}

- (NSUInteger)hash {
    NSUInteger observerContextHash = [[NSString stringWithFormat:@"%p-%p", _observer, _context] hash];
    return observerContextHash ^ _property.hash ^ _options;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (![object isKindOfClass:object_getClass(self)]) return NO;
    YAKeyValueObservance *other = (YAKeyValueObservance *)object;
    return other.observer == self.observer &&
    other.options == self.options &&
    other.context == self.context;
}
@end



/// 包装YAKeyValueObservance数组
@interface YAKeyValueObservationInfo : NSObject
@property (nonatomic, strong) NSArray <YAKeyValueObservance *> *observances;
- (instancetype)initWithObservances:(NSArray <YAKeyValueObservance *> *)observances
                              count:(NSUInteger)count;
@end
@implementation YAKeyValueObservationInfo
- (instancetype)initWithObservances:(NSArray<YAKeyValueObservance *> *)observances
                              count:(NSUInteger)count {
    if (self = [super init]) {
        _observances = [[NSArray alloc] initWithArray:observances];
    }
    return self;
}
@end



/// 配置YAKeyValueObservationInfoKey，去查询匹配的YAKeyValueObservationInfo
@interface YAKeyValueObservationInfoKey : NSObject
@property (nonatomic, strong) YAKeyValueObservationInfo *baseObservationInfo;
@property (nonatomic, strong) NSObject *additionObserver;
@property (nonatomic, strong) YAKeyValueProperty *additionProperty;
@property (nonatomic, assign) NSUInteger additionOptions;
@property (nonatomic, assign) void* additionContext;
@end
@implementation YAKeyValueObservationInfoKey
@end



#pragma mark - Private methods
BOOL YAKeyValuePropertyIsEqual(YAKeyValueProperty *property1, YAKeyValueProperty *property2) {
    return (property1.originalClass == property2.originalClass) &&
    (property1.keyPath == property2.keyPath || [property1.keyPath isEqual: property2.keyPath]);
}

NSUInteger YAKeyValuePropertyHash(YAKeyValueProperty *property) {
    return property.keyPath.hash ^ (NSUInteger)(__bridge void *)property.originalClass;
}

// 获取YAKeyValueProperty
static inline YAKeyValueProperty *getKeyValueProperty(Class cls, NSString *keyPath) {
    // 缓存集合
    static CFMutableSetRef YAKeyValueProperties;
    if(!YAKeyValueProperties) {
        // 创建YAKeyValueProperties
        CFSetCallBacks callbacks = {0};
        callbacks.version =  kCFTypeSetCallBacks.version;
        callbacks.retain =  kCFTypeSetCallBacks.retain;
        callbacks.release =  kCFTypeSetCallBacks.release;
        callbacks.copyDescription =  kCFTypeSetCallBacks.copyDescription;
        callbacks.equal =  (CFSetEqualCallBack)YAKeyValuePropertyIsEqual;
        callbacks.hash =  (CFSetHashCallBack)YAKeyValuePropertyHash;
        YAKeyValueProperties = CFSetCreateMutable(NULL, 0, &callbacks);
    }
    static YAKeyValueProperty *finder;
    if (!finder) finder = [YAKeyValueProperty new];
    finder.originalClass = cls;
    finder.keyPath = keyPath;
    YAKeyValueProperty *property = CFSetGetValue(YAKeyValueProperties, (__bridge const void *)(finder));
    if (!property) {
        // 缓存中没有找到, 创建
        property = [[YAKeyValueProperty alloc] initWithOriginalClass:cls keyPath:keyPath];
        // 添加到缓存中
        CFSetAddValue(YAKeyValueProperties, (__bridge const void *)(property));
    }
    return property;
}

// 获取YAKeyValueObservance
static inline YAKeyValueObservance *getKeyValueObservance(YAKeyValueProperty *property,
                                                          id observer,
                                                          void *context,
                                                          int options) {
    static NSHashTable *YAKeyValueShareableObservances;
    if (!YAKeyValueShareableObservances) {
        YAKeyValueShareableObservances = [NSHashTable weakObjectsHashTable];
    }
    static YAKeyValueObservance *finder;
    if (!finder) finder = [YAKeyValueObservance new];
    finder.property = property;
    finder.context = context;
    finder.observer = observer;
    finder.options = options;
    YAKeyValueObservance *observance = [YAKeyValueShareableObservances member:finder];
    if (!observance) {
        // 缓存中没有找到, 创建
        observance = [[YAKeyValueObservance alloc] initWithObserver:observer property:property options:options context:context];
        // 添加到缓存中
        [YAKeyValueShareableObservances addObject:observance];
    }
    return observance;
}

NSUInteger YAKeyValueObservationInfoNSHTHash(const void *item, NSUInteger (*size)(const void *item)) {
    if (object_getClass((__bridge id)item) == YAKeyValueObservationInfoKey.class) {
        YAKeyValueObservationInfoKey *key = (__bridge YAKeyValueObservationInfoKey *)item;
        return key.baseObservationInfo.observances.firstObject.hash;
    } else {
        YAKeyValueObservationInfo *info = (__bridge YAKeyValueObservationInfo *)item;
        return info.observances.firstObject.hash;
    }
}

BOOL YAKeyValueObservationInfoNSHTIsEqual(const void *item1, const void *item2, NSUInteger (* size)(const void * item)) {
    // 这里仅仅写了YAKeyValueObservationInfoKey与YAKeyValueObservationInfo的比较
    if (object_getClass((__bridge id)item1) == YAKeyValueObservationInfoKey.class || object_getClass((__bridge id)item2) == YAKeyValueObservationInfoKey.class) {
        YAKeyValueObservationInfo *info = nil;
        YAKeyValueObservationInfoKey *key = nil;
        
        // 确定哪一个是info, 哪一个是key
        if (object_getClass((__bridge id)item1) == YAKeyValueObservationInfoKey.class) {
            info = (__bridge YAKeyValueObservationInfo *)item2;
            key = (__bridge YAKeyValueObservationInfoKey *)item1;
        } else {
            info = (__bridge YAKeyValueObservationInfo *)item1;
            key = (__bridge YAKeyValueObservationInfoKey *)item2;
        }
        NSArray <YAKeyValueObservance *> *observancesInKey = key.baseObservationInfo.observances;
        NSArray <YAKeyValueObservance *> *observancesInInfo = info.observances;
        // key中observance的数量
        NSUInteger countInkey = observancesInKey.count;
        // info中observance的数量
        NSUInteger countInInfo = observancesInInfo.count;
        if (countInkey != countInInfo) return NO;
        for (NSUInteger i = 0; i < countInkey; i++) {
            // 保证每个observance完全匹配
            if (observancesInKey[i] != observancesInInfo[i]) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}



#pragma mark - Public methods
@implementation NSObject(YAKVO)
CFMutableDictionaryRef YAKeyValueObservationInfoPerObject = NULL;
- (void *)ya_observationInfo {
    return YAKeyValueObservationInfoPerObject ? (void *)CFDictionaryGetValue(YAKeyValueObservationInfoPerObject, OBSERVATION_INFO_KEY(self)) : NULL;
}

- (void)setYa_observationInfo:(void *)info {
    if (!YAKeyValueObservationInfoPerObject) {
        CFDictionaryValueCallBacks callbacks = {0};
        callbacks.version = kCFTypeDictionaryKeyCallBacks.version;
        callbacks.retain = kCFTypeDictionaryKeyCallBacks.retain;
        callbacks.release = kCFTypeDictionaryKeyCallBacks.release;
        callbacks.copyDescription = kCFTypeDictionaryKeyCallBacks.copyDescription;
        YAKeyValueObservationInfoPerObject = CFDictionaryCreateMutable(NULL, 0, NULL, &callbacks);
    }
    if (info) {
        CFDictionarySetValue(YAKeyValueObservationInfoPerObject, OBSERVATION_INFO_KEY(self), info);
    } else {
        CFDictionaryRemoveValue(YAKeyValueObservationInfoPerObject, OBSERVATION_INFO_KEY(self));
    }
}

- (void)ya_willChangeValueForKey:(NSString *)key {
    if (!YAKeyValueChangeDictionary) {
        YAKeyValueChangeDictionary = [NSMutableDictionary dictionary];
    }
    id oldValue = nil;
    oldValue = [self valueForKeyPath:key];
    if (!oldValue) oldValue = [NSNull null];
    [YAKeyValueChangeDictionary setObject:oldValue forKey:[NSString stringWithFormat:@"%p-old", self]];
}

- (void)ya_didChangeValueForKey:(NSString *)key {
    if (self.ya_isKVOClass) {
        YAKeyValueProperty *property = getKeyValueProperty(self.class, key);
        YAKeyValueObservationInfo *observation = self.ya_observationInfo;
        [observation.observances enumerateObjectsUsingBlock:^(YAKeyValueObservance *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.property isEqual:property]) {
                NSMutableDictionary *change = [NSMutableDictionary dictionary];
                if (obj.options & NSKeyValueObservingOptionOld) {
                    id old = [YAKeyValueChangeDictionary objectForKey:[NSString stringWithFormat:@"%p-old", self]];
                    [change setObject:old forKey:@"old"];
                } else {
                    [YAKeyValueChangeDictionary removeObjectForKey:[NSString stringWithFormat:@"%p-old", self]];
                }
                
                if (obj.options & NSKeyValueObservingOptionNew) {
                    id newValue = nil;
                    newValue = [self valueForKeyPath:key];
                    if (!newValue) newValue = [NSNull null];
                    [YAKeyValueChangeDictionary setObject:newValue forKey:[NSString stringWithFormat:@"%p-new", self]];
                    [change setObject:newValue forKey:@"new"];
                }
                [obj.observer ya_observeValueForKeyPath:key ofObject:self change:change context:nil];
            }
        }];
    }
}

- (void)ya_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context {

    YAKeyValueProperty *property = getKeyValueProperty(self.class, keyPath);
    YAKeyValueObservance *observance = getKeyValueObservance(property, observer, context, options);
    
    static NSHashTable *YAKeyValueShareableObservationInfos;
    if (!YAKeyValueShareableObservationInfos) {
        NSPointerFunctions *pointerFunctions = [[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory];
        [pointerFunctions setHashFunction:YAKeyValueObservationInfoNSHTHash];
        [pointerFunctions setIsEqualFunction:YAKeyValueObservationInfoNSHTIsEqual];
        YAKeyValueShareableObservationInfos = [[NSHashTable alloc] initWithPointerFunctions:pointerFunctions capacity:0];
    }
    static YAKeyValueObservationInfoKey *finder;
    if (!finder) {
        finder = [YAKeyValueObservationInfoKey new];
    }
    
    YAKeyValueObservationInfo *info = (__bridge id)[self ya_observationInfo];
    finder.baseObservationInfo = info;
    finder.additionObserver = observer;
    finder.additionContext = context;
    finder.additionOptions = options;
    finder.additionProperty = property;
    
    YAKeyValueObservationInfo *observation = [YAKeyValueShareableObservationInfos member:finder];
    // 重置finder数据
    finder.baseObservationInfo = nil;
    finder.additionObserver = nil;
    finder.additionContext = NULL;
    finder.additionOptions = 0;
    finder.additionProperty = nil;
    
    if (!observation) {
        // 缓存中没有找到, 创建
        observation = [[YAKeyValueObservationInfo alloc] initWithObservances:@[observance] count:1];
        // 添加到缓存中
        [YAKeyValueShareableObservationInfos addObject:observation];
    } else {
        NSMutableArray *buffer = [NSMutableArray arrayWithArray:observation.observances];
        [buffer addObject:observance];
        observation.observances = [NSArray arrayWithArray:buffer];
    }
    self.ya_observationInfo = (__bridge void *)(observation);
    
    if (!self.ya_isKVOClass) {
        Class isaForAutonotifying = [property isaForAutonotifying];
        // 更改isa指针
        object_setClass(self, isaForAutonotifying);
    }
    
    if (options & NSKeyValueObservingOptionInitial) {
        id newValue = nil;
        if (options & NSKeyValueObservingOptionNew) {
            newValue = [self valueForKeyPath:keyPath];
        }
        if (!newValue) newValue = [NSNull null]; // 使用NSNull对象
        NSDictionary *change = @{@"new": newValue};
        [observer ya_observeValueForKeyPath:keyPath ofObject:self change:change context:context];
    }
}

- (void)ya_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    if (self.ya_isKVOClass) {
        YAKeyValueProperty *property = getKeyValueProperty(self.class, keyPath);
        YAKeyValueObservationInfo *observation = self.ya_observationInfo;
        NSMutableArray *diff = [NSMutableArray arrayWithArray:observation.observances];
        __block NSInteger removeIdx = -1;
        [diff enumerateObjectsUsingBlock:^(YAKeyValueObservance *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.property isEqual:property] && obj.observer == observer && obj.context == context) {
                removeIdx = idx;
                *stop = YES;
            }
        }];
        if (removeIdx != -1) {
            // 找到需要移除的元素
            [diff removeObjectAtIndex:removeIdx];
            observation.observances = [NSArray arrayWithArray:diff];
        }
    }
}

- (void)ya_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{}
@end
