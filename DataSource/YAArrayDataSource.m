//
//  YAArrayDataSource.m
//  YAArrayDataSource
//
//  Created by Aaron on 2018/5/7.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//

#import "YAArrayDataSource.h"

@interface YAArrayDataSource () 
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) YACellHandler cellHandler;
@end

@implementation YAArrayDataSource
#pragma mark - Life cycle
- (instancetype)initWithDataArray:(NSArray *)array cellIdentifier:(NSString *)identifier configureCellHandler:(YACellHandler)handler {
    if (self = [super init]) {
        self.dataArray = [NSMutableArray arrayWithArray:array];
        self.cellIdentifier = identifier;
        self.cellHandler = handler;
    }
    return self;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    id model = [self itemAtIndexPath:indexPath];
    if (self.cellHandler) { self.cellHandler(cell, model); }
    return cell;
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    id model = [self itemAtIndexPath:indexPath];
    if (self.cellHandler) { self.cellHandler(cell, model); }
    return cell;
}

#pragma mark - Event response
- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataArray[(NSUInteger) indexPath.row];
}
@end
