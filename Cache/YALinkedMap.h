//
//  YALinkedMap.h
//  Aaron
//
//  Created by Chen,Yalun on 2018/12/27.
//  Copyright © 2018 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface YALinkedMapNode : NSObject
@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) id value;
@end

@interface YALinkedMap : NSObject
- (void)insertNodeAtHead:(YALinkedMapNode *)node;
- (void)bringNodeToHead:(YALinkedMapNode *)node;
- (void)removeNode:(YALinkedMapNode *)node;
- (YALinkedMapNode *)removeTailNode;
- (void)removeAll;
- (NSArray *)allNodes;
@end

NS_ASSUME_NONNULL_END
