//
//  YANestedScrollViewController.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/3/21.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YANestedScrollViewController.h"

@interface YAMainScrollView : UIScrollView
@end
@implementation YAMainScrollView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70, 100, frame.size.width, 100)];
    label.text = @"我在main scroll view上面";
    [self addSubview:label];
    self.backgroundColor = UIColor.orangeColor;
    self.showsVerticalScrollIndicator = NO;
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 设置允许手势穿透
    return YES;
}
@end



@interface YASubScrollView : UITableView <UITableViewDataSource>
@end
@implementation YASubScrollView
static NSString *identifier = @"identifier";
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.showsVerticalScrollIndicator = NO;
        self.rowHeight = 60;
        self.dataSource = self;
        [self registerClass:UITableViewCell.class forCellReuseIdentifier:identifier];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = @"lable";
    return cell;
}
@end



// sub scroll view初始Y
#define kSubScrollViewFromY 280
// sub scroll view结束Y
#define kSubScrollViewEndY 100
// main scroll view高度
#define kMainScrollViewHeight (kScreenHeight - 20)
// sub scroll view高度
#define kSubScrollViewHeight (kScreenHeight - kSubScrollViewEndY)
// 边界值
#define kEdgeOffsetY (kSubScrollViewFromY + kSubScrollViewHeight - kMainScrollViewHeight)
@interface YANestedScrollViewController () <UIScrollViewDelegate, UITableViewDelegate>
@end
@implementation YANestedScrollViewController {
    UIScrollView *_main;
    UIScrollView *_sub;
    // 用一个变量标志main scroll view 是否可滑动
    BOOL mainCanScroll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    YAMainScrollView *main = [[YAMainScrollView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, kMainScrollViewHeight)];
    main.contentSize = CGSizeMake(0, kSubScrollViewHeight + kSubScrollViewFromY);
    main.delegate = self;
    _main = main;
    [self.view addSubview:main];
    
    YASubScrollView *sub = [[YASubScrollView alloc] initWithFrame:CGRectMake(0, kSubScrollViewFromY, kScreenWidth, kSubScrollViewHeight) style:UITableViewStylePlain];
    sub.delegate = self;
    _sub = sub;
    [main addSubview:sub];
    mainCanScroll = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (mainCanScroll) {
        _sub.contentOffset = CGPointZero;
    } else  {
        _main.contentOffset = CGPointMake(0, kEdgeOffsetY);
    }
    
    mainCanScroll = (_main.contentOffset.y < kEdgeOffsetY || _sub.contentOffset.y < 0);
    // 修复_sub滑动到底部没有bounce
    _main.scrollEnabled = (_sub.contentSize.height - _sub.frame.size.height > _sub.contentOffset.y);
}
@end







