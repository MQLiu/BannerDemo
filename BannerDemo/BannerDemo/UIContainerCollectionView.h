//
//  UIContainerCollectionView.h
//  collectionViewTransverse
//
//  Created by 余天龙 on 16/7/5.
//  Copyright © 2016年 YuTianLong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WBScrollType) {
    
    WBScrollTypeFree ,      //自由惯性
    WBScrollTypePage        //分页的
};

@interface UIContainerCollectionView : UIView

- (void)setupWithDataSource:(NSArray<id> *)dataSource pointValue:(NSValue *)pointValue;

@property (nonatomic, copy) void (^pointChangeBlock)(NSValue *pointValue);

@property (nonatomic, assign) WBScrollType scrollType;      //默认是分页的

@property (nonatomic, copy) void (^didSelectItemBlock)(NSUInteger section, NSUInteger row);

@end
