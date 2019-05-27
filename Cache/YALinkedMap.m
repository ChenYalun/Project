//
//  YALinkedMap.m
//  Aaron
//
//  Created by Chen,Yalun on 2018/12/27.
//  Copyright © 2018 Chen,Yalun. All rights reserved.
//

#import "YALinkedMap.h"

@interface YALinkedMapNode () {
    @package
    __unsafe_unretained YALinkedMapNode *_prev;
    __unsafe_unretained YALinkedMapNode *_next;
}
@end
@implementation YALinkedMapNode
@end



@interface YALinkedMap () {
    NSMutableDictionary *_map;
    YALinkedMapNode *_head;
    YALinkedMapNode *_tail;
}

@end
@implementation YALinkedMap
- (instancetype)init {
    self = [super init];
    _map = [NSMutableDictionary dictionary];
    return self;
}

- (void)dealloc {
    [_map removeAllObjects];
}

#pragma mark - Public methods
- (void)insertNodeAtHead:(YALinkedMapNode *)node {
    if (!node.key || node.key.length == 0) return;
    [_map setObject:node forKey:node.key];
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

- (void)bringNodeToHead:(YALinkedMapNode *)node {
    if (_head == node) return;
    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    } else {
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

- (void)removeNode:(YALinkedMapNode *)node {
    [_map removeObjectForKey:node.key];
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}

- (YALinkedMapNode *)removeTailNode {
    if (!_tail) return nil;
    YALinkedMapNode *tail = _tail;
    [_map removeObjectForKey:_tail.key];
    if (_head == _tail) {
        _head = _tail = nil;
    } else {
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return tail;
}

- (void)removeAll {
    _head = nil;
    _tail = nil;
    [_map removeAllObjects];
}

- (NSArray *)allNodes {
    if (!_head) return nil;
    NSMutableArray *tmp = [NSMutableArray array];
    YALinkedMapNode *head = _head;
    [tmp addObject:head];
    while (head->_next) {
        [tmp addObject:head->_next];
        head = head->_next;
    }
    return [tmp copy];
}
@end
