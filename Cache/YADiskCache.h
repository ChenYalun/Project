//
//  YADiskCache.h
//  Aaron
//
//  Created by Chen,Yalun on 2018/12/27.
//  Copyright © 2018 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YADiskCache : NSObject
@property (nonatomic, copy) NSString *path;
- (NSData *)objectForKey:(NSString *)key;
- (BOOL)setObject:(NSData *)obj forKey:(NSString *)key;
- (BOOL)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;
@end

NS_ASSUME_NONNULL_END
