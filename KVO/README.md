### 关于
KVO的简单实践。

### 简介
添加观察者，属性更改时得到回调。

### 使用
#### 接口

```
@interface NSObject(YAKVO)
@property void *ya_observationInfo;

- (void)ya_willChangeValueForKey:(NSString *)key;
- (void)ya_didChangeValueForKey:(NSString *)key;
- (void)ya_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)ya_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)ya_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;
@end
```

#### 添加

```
[self.obj ya_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:"NULL"];
self.obj.name = @"Aaron";
```

#### 回调

```
- (void)ya_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@", change);
}
```




