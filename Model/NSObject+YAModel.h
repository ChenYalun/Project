//
//  NSObject+YAModel.h
//  Aaron
//
//  Created by Chen,Yalun on 2018/12/20.
//  Copyright © 2018 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YAModelProtocol <NSObject>
@optional;
+ (NSDictionary <NSString *, NSString *> *)customPropertyKey;
+ (NSDictionary <NSString *, Class>*)classInArray;
@end


@interface NSObject (YAModel)
+ (instancetype)ya_modelWithDictionary:(NSDictionary *)dict;
+ (instancetype)ya_modelWithJSON:(NSData *)data;
+ (NSArray *)ya_modelArrayWithKeyValuesArray:(NSArray <NSDictionary *>*)dictArray;
@end
