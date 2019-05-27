//
//  YADiskCache.m
//  Aaron
//
//  Created by Chen,Yalun on 2018/12/27.
//  Copyright © 2018 Chen,Yalun. All rights reserved.
//

#import "YADiskCache.h"
@implementation YADiskCache
- (NSData *)objectForKey:(NSString *)key {
    NSString *path = [_path stringByAppendingPathComponent:key];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

- (BOOL)setObject:(NSData *)obj forKey:(NSString *)key {
    NSString *path = [_path stringByAppendingPathComponent:key];
    return [obj writeToFile:path atomically:NO];
}

- (BOOL)removeObjectForKey:(NSString *)key {
    NSString *path = [_path stringByAppendingPathComponent:key];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)removeAllObjects {
    NSFileManager *manager = [NSFileManager new];
    NSArray *directoryContents = [manager contentsOfDirectoryAtPath:_path error:NULL];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSString *path in directoryContents) {
            NSString *fullPath = [self->_path stringByAppendingPathComponent:path];
            [manager removeItemAtPath:fullPath error:NULL];
        }
    });
}
@end

