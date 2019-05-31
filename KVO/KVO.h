//
//  KVO.h
//  Aaron
//
//  Created by Chen,Yalun on 2019/5/21.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(YAKVO)
@property void *ya_observationInfo;

- (void)ya_willChangeValueForKey:(NSString *)key;
- (void)ya_didChangeValueForKey:(NSString *)key;
- (void)ya_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)ya_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)ya_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;
@end


