//
//  UIContainerCollectionView.m
//  collectionViewTransverse
//
//  Created by 余天龙 on 16/7/5.
//  Copyright © 2016年 YuTianLong. All rights reserved.
//

#import "UIContainerCollectionView.h"
#import "Masonry.h"
#import "ImageViewCollectionViewCell.h"

#define CONTENTOFFSET_X         (20)

@interface UIContainerCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSString *> *imageNameds;

@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) NSInteger contentSizeWidth;

//这两个属性只在 分页情况 下使用。
@property (nonatomic, assign) NSUInteger row;                   //记录滑之前的row（用于计算滑动需要到的位置）
@property (nonatomic, assign) NSUInteger currentRow;            //记录上一次的row (用于判断是否是当前row, 如果没有改变，则不刷新) *if (self.currentRow == self.row)*

@end

@implementation UIContainerCollectionView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isFirst) {
        self.isFirst = NO;
        self.contentSizeWidth = (self.collectionView.frame.size.width - CONTENTOFFSET_X * 2) * self.imageNameds.count + 10 * (self.imageNameds.count - 1);
        self.collectionView.contentInset = UIEdgeInsetsMake(0, CONTENTOFFSET_X, 0, 0);
    }
}

#pragma mark - Getter , Setter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.decelerationRate = self.scrollType == WBScrollTypePage ? 0.1f : 1.0f;
    }
    return _collectionView;
}

- (void)setScrollType:(WBScrollType)scrollType {
    _scrollType = scrollType;
    _collectionView.decelerationRate = self.scrollType == WBScrollTypePage ? 0.1f : 1.0f;
}

- (void)setupWithDataSource:(NSArray<id> *)dataSource pointValue:(NSValue *)pointValue {
    self.imageNameds = dataSource;
    [self.collectionView reloadData];
    [self adjustCollectionViewContentOffsetXIfNeededWithPoint:pointValue];
}

- (void)adjustCollectionViewContentOffsetXIfNeededWithPoint:(NSValue *)pointValue {
    
    if (pointValue == nil) {
        [self.collectionView setContentOffset:CGPointMake(- CONTENTOFFSET_X, 0) animated:NO];
        return;
    }
    NSUInteger cellWidth = self.collectionView.frame.size.width - CONTENTOFFSET_X * 2;
    CGPoint point = [pointValue CGPointValue];
    self.row = point.x / ((cellWidth + CONTENTOFFSET_X / 2.0) - CONTENTOFFSET_X);
    self.currentRow = self.row;
    [self.collectionView setContentOffset:point animated:NO];
}

#pragma mark - Private methods

- (void)setupUI {

    self.isFirst = YES;
    
    self.scrollType = WBScrollTypePage;
    self.row = 0;               //从0开始
    self.currentRow = self.row;
    
    [self.collectionView registerClass:[ImageViewCollectionViewCell class] forCellWithReuseIdentifier:[ImageViewCollectionViewCell reuseIdentifier]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(@0);
    }];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    
    CGPoint estimateContentOffset = CGPointMake(targetContentOffset -> x, targetContentOffset -> y);
    CGPoint currentPoint = [self itemCenterOffsetWithOriginalTargetContentOffset:estimateContentOffset];
    
    self.pointChangeBlock([NSValue valueWithCGPoint:currentPoint]);
    
    //分页情况的优化。
    if (self.scrollType == WBScrollTypePage) {
        //这次滑动停止的item 和 上一次位置一样 (同一个位置)，则友好的回到当前
        if (self.currentRow == self.row) {
            
            [self scrollViewToIndexRow];
            return;
        }
        self.currentRow = self.row;
    }
    *targetContentOffset = currentPoint;
}

- (void)scrollViewToIndexRow {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.row inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
    NSUInteger cellWidth = self.collectionView.frame.size.width - CONTENTOFFSET_X * 2;
    CGPoint point = CGPointMake(self.row * (cellWidth + CONTENTOFFSET_X / 2.0) - CONTENTOFFSET_X, 0);
    [_collectionView setContentOffset:point animated:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
    }];
}

- (CGPoint)itemCenterOffsetWithOriginalTargetContentOffset:(CGPoint)orifinalTargetContentOffset {
    
    if (self.scrollType == WBScrollTypeFree) {  //自由惯性的
        
        CGFloat pageWidth = self.contentSizeWidth / (CGFloat)self.imageNameds.count;
        NSUInteger cellWidth = self.collectionView.frame.size.width - CONTENTOFFSET_X * 2;
        NSInteger row = 0;
        CGPoint point ;
        
        if (orifinalTargetContentOffset.x <= pageWidth / 2.0) {
            row = 0;
            point = CGPointMake(row * (cellWidth + CONTENTOFFSET_X / 2.0) - CONTENTOFFSET_X, 0);
            self.collectionView.contentInset = UIEdgeInsetsMake(0, CONTENTOFFSET_X, 0, 0);
            return point;
        }
        if (orifinalTargetContentOffset.x > self.contentSizeWidth - cellWidth * 2 + pageWidth / 2.0) {
            row = self.imageNameds.count - 1;
            point = CGPointMake(row * (cellWidth + CONTENTOFFSET_X / 2.0) - CONTENTOFFSET_X, 0);
            self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, CONTENTOFFSET_X);
            return point;
        }
        
        NSUInteger index = orifinalTargetContentOffset.x / pageWidth;
        row = index + (orifinalTargetContentOffset.x - pageWidth * index > pageWidth / 2.0 ? 1 : 0);
        
        point = CGPointMake(row * (cellWidth + CONTENTOFFSET_X / 2.0) - CONTENTOFFSET_X, 0);
        return point;
        
    } else { //分页的
        
        CGFloat pageWidth = self.contentSizeWidth / (CGFloat)self.imageNameds.count;
        NSUInteger cellWidth = self.collectionView.frame.size.width - CONTENTOFFSET_X * 2;
        NSInteger row = 0;
        CGPoint point ;
        
        CGFloat scrollBeforeContentOffsetX = self.row * (cellWidth + CONTENTOFFSET_X / 2.0) - CONTENTOFFSET_X;      //滑动之前的 X 位置
        NSUInteger scrollDirection = orifinalTargetContentOffset.x - scrollBeforeContentOffsetX >= 0.0 ? 1 : 0;     //1向右， 0向左
        
        if (orifinalTargetContentOffset.x == -CONTENTOFFSET_X) {
            scrollDirection = 0;
        }
        
        if (fabs(orifinalTargetContentOffset.x - scrollBeforeContentOffsetX) > pageWidth * 1.5) {
            // + 2
            
            row = (scrollDirection == 0) ? (self.row - 2) : (self.row + 2);
        } else if (fabs(orifinalTargetContentOffset.x - scrollBeforeContentOffsetX) > pageWidth * 0.2) {
            // + 1
            
            row = scrollDirection == 0 ? (self.row - 1) : (self.row + 1);
        } else {
            
            row = self.row;
        }
        
        row = row < 0 ? 0 : row;
        row = row > self.imageNameds.count - 1 ? (self.imageNameds.count - 1) : row;
        self.row = row;
        
        if (row == 0) {
            self.collectionView.contentInset = UIEdgeInsetsMake(0, CONTENTOFFSET_X, 0, 0);
        }
        
        if (row == self.imageNameds.count - 1) {
            self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, CONTENTOFFSET_X);
        }
        
        point = CGPointMake(row * (cellWidth + CONTENTOFFSET_X / 2.0) - CONTENTOFFSET_X, 0);
        return point;
    }
    return CGPointMake(0, 0);
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageNameds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageViewCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    
    [cell setupWithImageNamed:self.imageNameds[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(collectionView.frame.size.width - CONTENTOFFSET_X * 2, collectionView.frame.size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return CONTENTOFFSET_X / 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.didSelectItemBlock(indexPath.section, indexPath.row);
}

@end
