//
//  ViewController.m
//  BannerDemo
//
//  Created by liumaoqiang on 16/10/11.
//  Copyright © 2016年 liumaoqiang. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "UIContainerCollectionView.h"
#import "ImageViewCollectionViewCell.h"

#define CONTENTOFFSET_X         (20)

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger contentSizeWidth;
@property (nonatomic, strong) NSArray<NSString *> *imageNameds;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) CGFloat pageWidth;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIImageView *heihei;

@property (strong, nonatomic) UIImageView *screenShoot;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) CGRect screenShootFrame;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageNameds = @[@"1",@"2",@"3"];
    [self.collectionView registerClass:[ImageViewCollectionViewCell class] forCellWithReuseIdentifier:[ImageViewCollectionViewCell reuseIdentifier]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.pageIndex = 0;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(@0);
        make.height.equalTo(@200);
    }];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = self.imageNameds.count;
    [self.view addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.collectionView);
        make.bottom.equalTo(self.collectionView).offset(-20);
    }];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    [self.view layoutIfNeeded];
    self.screenShootFrame = self.imageView.frame;
    
    
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 3;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    
    [self.heihei.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self screenhaahhah];
//
//    for (UIView *view in self.view.subviews) {
//        if (view == self.screenShoot) {
//            continue;
//        }
//        [view removeFromSuperview];
//    }
    [self.heihei.layer removeAllAnimations];
}

- (void)screenhaahhah {
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES,0);//设置截屏大小
    
    [[self.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = viewImage.CGImage;
    
    //CGRect rect = CGRectMake(166, 211, 426, 320);//这里可以设置想要截图的区域
    
//    CGRect rect = CGRectMake(0,0, iPadWidth, iPadHeight);//这里可以设置想要截图的区域
    
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, self.screenShootFrame);
    
    UIImage *sendImage =[[UIImage alloc] initWithCGImage:imageRefRect];
    [self.screenShoot setImage:sendImage];
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    UIRectClip(self.imageView.frame);
//    [self.view.layer renderInContext:context];
//    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [self.screenShoot setImage:theImage];
}

- (UIImageView *)screenShoot {
    if (!_screenShoot) {
        _screenShoot = [[UIImageView alloc] initWithFrame:self.screenShootFrame];
//        _screenShoot.contentMode = UIViewContentModeScaleAspectFit;
        _screenShoot.backgroundColor = [UIColor blueColor];
        [self.view addSubview:_screenShoot];
    }
    return _screenShoot;
}

- (void)autoScroll {
    [self.collectionView setContentOffset:CGPointMake(self.pageWidth * (self.row ++) - CONTENTOFFSET_X, 0) animated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //    self.contentSizeWidth = (self.collectionView.frame.size.width - CONTENTOFFSET_X * 2) * 10000 + 10 * (10000 - 1);
    self.pageWidth = self.collectionView.frame.size.width - CONTENTOFFSET_X / 2 * 3;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, CONTENTOFFSET_X / 2, 0, 0);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint estimateContentOffset = CGPointMake(targetContentOffset -> x, targetContentOffset -> y);
    CGPoint currentPoint = [self itemCenterOffsetWithOriginalTargetContentOffset:estimateContentOffset];
    *targetContentOffset = currentPoint;
}

/**
 *  @author liumaoqiang
 *
 *  翻页功能--计算修正后的contentOffset
 *
 *  @param orifinalTargetContentOffset 手松开后的contenOfset
 *
 *  @return 修正后的contentOffset
 */
- (CGPoint)itemCenterOffsetWithOriginalTargetContentOffset:(CGPoint)orifinalTargetContentOffset {
    //一个cell的宽度
    NSUInteger cellWidth = self.collectionView.frame.size.width - CONTENTOFFSET_X * 2;
    NSInteger row = 0;
    CGPoint point ;
    //滑动之前的 X 位置
    CGFloat scrollBeforeContentOffsetX = self.row * (cellWidth + CONTENTOFFSET_X / 2.0) - CONTENTOFFSET_X;
    NSUInteger scrollDirection = orifinalTargetContentOffset.x - scrollBeforeContentOffsetX >= 0.0 ? 1 : 0;     //1向右， 0向左
    
    if (orifinalTargetContentOffset.x == -CONTENTOFFSET_X) {
        scrollDirection = 0;
    }
    
    if (fabs(orifinalTargetContentOffset.x - scrollBeforeContentOffsetX) > self.pageWidth * 1.5) {//滑动距离大于翻页的距离则翻两页
        row = (scrollDirection == 0) ? (self.row - 2) : (self.row + 2);
    } else if (fabs(orifinalTargetContentOffset.x - scrollBeforeContentOffsetX) > self.pageWidth * 0.5) {//大于半页则进行翻页
        row = scrollDirection == 0 ? (self.row - 1) : (self.row + 1);
    } else {
        row = self.row;
    }
    
    row = row < 0 ? 0 : row;
    //    row = row > self.imageNameds.count - 1 ? (self.imageNameds.count - 1) : row;
    self.row = row;
    
    if (row == 0) {
        self.collectionView.contentInset = UIEdgeInsetsMake(0, CONTENTOFFSET_X, 0, 0);
    }
    
    //    if (row == self.imageNameds.count - 1) {
    //        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, CONTENTOFFSET_X);
    //    }
    
    point = CGPointMake(row * (cellWidth + CONTENTOFFSET_X / 2.0) - CONTENTOFFSET_X, 0);
    return point;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"===%zd",(NSInteger)(scrollView.contentOffset.x / self.pageWidth + 0.5));
    self.pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x / self.pageWidth + 0.5) % self.imageNameds.count;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x / self.pageWidth + 0.5) % self.imageNameds.count;
}

#pragma mark - UICollectionViewDataSource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ImageViewCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    NSInteger count = indexPath.row;
    if (indexPath.row >= self.imageNameds.count) {
        count = indexPath.row % self.imageNameds.count;
    }
    [cell setupWithImageNamed:self.imageNameds[count]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(collectionView.frame.size.width - CONTENTOFFSET_X * 2, collectionView.frame.size.height - 20);
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
    
    
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor lightGrayColor];
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.decelerationRate = 0.1f;
    }
    return _collectionView;
}
@end
