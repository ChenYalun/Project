//
//  YAArrayDataSource.h
//  YAArrayDataSource
//
//  Created by Aaron on 2018/5/7.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^YACellHandler)(id cell, id model);

@interface YAArrayDataSource : NSObject <UITableViewDataSource, UICollectionViewDataSource>

/**
 Creates a data source delegte.

 @param array A model array.
 @param identifier The identifier of table view cell.
 @param handler A block handler of table view cell.
 @return A new instance, or nil if an error occurs.
 */
- (instancetype)initWithDataArray:(NSArray *)array
                   cellIdentifier:(NSString *)identifier
             configureCellHandler:(YACellHandler)handler;

/**
 Returns the corresponding object in the array according to the index.

 @param indexPath A indexPath.
 @return A model instance.
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

// The constructor method is disabled.
- (instancetype) init __attribute__((unavailable("init not available, call initWithDataArray:cellIdentifier:configureCellHandler: instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call initWithDataArray:cellIdentifier:configureCellHandler: instead")));
@end
