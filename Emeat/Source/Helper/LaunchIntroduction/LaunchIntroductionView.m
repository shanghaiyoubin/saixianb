//
//  LaunchIntroductionView.m
//  ZYGLaunchIntroductionDemo
//
//  Created by ZhangYunguang on 16/4/7.
//  Copyright © 2016年 ZhangYunguang. All rights reserved.
//

#import "LaunchIntroductionView.h"
#import "JMHoledView.h"
#import "NewUserGiftView.h"
#import "HWPopTool.h"
#import "HomePageOtherDetailsViewController.h"

static NSString *const kAppVersion = @"appVersion";

@interface LaunchIntroductionView ()<UIScrollViewDelegate , JMHoledViewDelegate>
{
    UIScrollView  *launchScrollView;
    UIPageControl *page;
    NSInteger newUserCount;

}
///新手用户引导
@property (nonatomic,strong) JMHoledView *jmHoledView;
///
@property (nonatomic,strong) UIImageView * NewUserView;

@end

@implementation LaunchIntroductionView
NSArray *images;
BOOL isScrollOut;//在最后一页再次滑动是否隐藏引导页
CGRect enterBtnFrame;
NSString *enterBtnImage;
static LaunchIntroductionView *launch = nil;
NSString *storyboard;

#pragma mark - 创建对象-->>不带button
+(instancetype)sharedWithImages:(NSArray *)imageNames{
    images = imageNames;
    isScrollOut = YES;
    launch = [[LaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}

#pragma mark - 创建对象-->>带button
+(instancetype)sharedWithImages:(NSArray *)imageNames buttonImage:(NSString *)buttonImageName buttonFrame:(CGRect)frame{
    images = imageNames;
    isScrollOut = NO;
    enterBtnFrame = frame;
    enterBtnImage = buttonImageName;
    launch = [[LaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}
#pragma mark - 用storyboard创建的项目时调用，不带button
+ (instancetype)sharedWithStoryboardName:(NSString *)storyboardName images:(NSArray *)imageNames {
    images = imageNames;
    storyboard = storyboardName;
    isScrollOut = YES;
    launch = [[LaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}
#pragma mark - 用storyboard创建的项目时调用，带button
+ (instancetype)sharedWithStoryboard:(NSString *)storyboardName images:(NSArray *)imageNames buttonImage:(NSString *)buttonImageName buttonFrame:(CGRect)frame{
    images = imageNames;
    isScrollOut = NO;
    enterBtnFrame = frame;
    storyboard = storyboardName;
    enterBtnImage = buttonImageName;
    launch = [[LaunchIntroductionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launch.backgroundColor = [UIColor whiteColor];
    return launch;
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"currentColor" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"nomalColor" options:NSKeyValueObservingOptionNew context:nil];
        if ([self isFirstLauch]) {
            UIStoryboard *story;
            if (storyboard) {
                story = [UIStoryboard storyboardWithName:storyboard bundle:nil];
            }
            UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
            if (story) {
                UIViewController * vc = story.instantiateInitialViewController;
                window.rootViewController = vc;
                [vc.view addSubview:self];
            }else {
                [window addSubview:self];
            }
            [self addImages];
        }else{
            [self removeFromSuperview];
        }
    }
    return self;
}
#pragma mark - 判断是不是首次登录或者版本更新
-(BOOL )isFirstLauch{
    //获取当前版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentAppVersion = infoDic[@"CFBundleShortVersionString"];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setValue:currentAppVersion forKey:@"appVersionNumbers"];
    [user setValue:@"2.2" forKey:@"appVersionNumber"];

    //获取上次启动应用保存的appVersion
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppVersion];
    //版本升级或首次登录
    if (version == nil || ![version isEqualToString:currentAppVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:kAppVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - 添加引导页图片
-(void)addImages{
    [self createScrollView];
}
#pragma mark - 创建滚动视图
-(void)createScrollView{
    launchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, kScreen_height)];
    launchScrollView.showsHorizontalScrollIndicator = NO;
    launchScrollView.bounces = NO;
    launchScrollView.pagingEnabled = YES;
    launchScrollView.delegate = self;
    launchScrollView.contentSize = CGSizeMake(kScreen_width * images.count, kScreen_height);
    [self addSubview:launchScrollView];
    for (int i = 0; i < images.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * kScreen_width, 0, kScreen_width, kScreen_height)];
        imageView.image = [UIImage imageNamed:images[i]];
        [launchScrollView addSubview:imageView];
        if (i == images.count - 1) {
            //判断要不要添加button
            if (!isScrollOut) {
                UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(enterBtnFrame.origin.x, enterBtnFrame.origin.y, enterBtnFrame.size.width, enterBtnFrame.size.height)];
                [enterButton setImage:[UIImage imageNamed:enterBtnImage] forState:UIControlStateNormal];
                [enterButton addTarget:self action:@selector(enterBtnClick) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:enterButton];
                imageView.userInteractionEnabled = YES;
            }
        }
    }
    page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreen_height - 36*kScale, kScreen_width, 30*kScale)];
    page.numberOfPages = images.count;
    page.backgroundColor = [UIColor clearColor];
    page.currentPage = 0;
    page.defersCurrentPageDisplay = YES;
    [self addSubview:page];
}
#pragma mark - 进入按钮
-(void)enterBtnClick{
    [self hideGuidView];
}
#pragma mark - 隐藏引导页
-(void)hideGuidView{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
            //后期加上 新手引导
            //[self addNewUserView];
            
            //添加新手礼包
           [self addNewGift];
        });
        
    }];
}
#pragma mark - scrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    int cuttentIndex = (int)(scrollView.contentOffset.x + kScreen_width/2)/kScreen_width;
    if (cuttentIndex == images.count - 1) {
        if ([self isScrolltoLeft:scrollView]) {
            if (!isScrollOut) {
                return ;
            }
            [self hideGuidView];
        }
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == launchScrollView) {
        int cuttentIndex = (int)(scrollView.contentOffset.x + kScreen_width/2)/kScreen_width;
        page.currentPage = cuttentIndex;
    }
}
#pragma mark - 判断滚动方向
-(BOOL )isScrolltoLeft:(UIScrollView *) scrollView{
    //返回YES为向左反动，NO为右滚动
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark - KVO监测值的变化
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentColor"]) {
        page.currentPageIndicatorTintColor = self.currentColor;
    }
    if ([keyPath isEqualToString:@"nomalColor"]) {
        page.pageIndicatorTintColor = self.nomalColor;
    }
}



#pragma mark ========添加新手大礼包

-(void)addNewGift{

    NewUserGiftView *upView = [[NewUserGiftView alloc] initWithFrame:CGRectMake(0, 145*kScale, kWidth, 300*kScale)];
    [upView.giftBtn addTarget:self action:@selector(clickGiftBtnAction) forControlEvents:1];
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeNone;
    [HWPopTool sharedInstance].tapOutsideToDismiss = YES;
    [[HWPopTool sharedInstance] showWithPresentView:upView animated:NO];

}







-(void)clickGiftBtnAction{
    DLog(@"拆礼包");
    __weak __typeof(self) weakSelf = self;
    
    [[HWPopTool sharedInstance] closeWithBlcok:^{
        HomePageOtherDetailsViewController *otherVC = [HomePageOtherDetailsViewController new];
        otherVC.detailsURL = [NSString stringWithFormat:@"%@/breaf/new_user_gift_pack_iOS.html" ,baseUrl];
        
        otherVC.hidesBottomBarWhenPushed = YES;
        //取出根视图控制器
        UITabBarController *tabBarVc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        //取出当前选中的导航控制器
        UINavigationController *Nav = [tabBarVc selectedViewController];
        [Nav pushViewController:otherVC animated:YES];
    }];
    
    
}



///////////////


#pragma maek =====添加新手用户引导

-(void)addNewUserView{
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.jmHoledView];
    [self.jmHoledView addHCustomView:[self clickForView] onRect:CGRectMake((kWidth-150*kScale)/2, kHeight-200*kScale, 150*kScale, 43*kScale)];
    
    [self.jmHoledView addHCustomView:[self viewForDemo] onRect:CGRectMake(0, 0, launchScrollView.frame.size.width, launchScrollView.frame.size.height)];
    [self.jmHoledView addHCustomView:[self clickForView] onRect:CGRectMake((kWidth-150*kScale)/2, kHeight-200*kScale, 150*kScale, 43*kScale)];
    
    
}


#pragma mark - JMHoledViewDelegate

- (void)holedView:(JMHoledView *)holedView didSelectHoleAtIndex:(NSUInteger)index
{
    //NSLog(@"%s %ld", __PRETTY_FUNCTION__,(long)index);
    
    if (index == 0) {
        newUserCount++;
        
        if (newUserCount == 1) {
            UIImage *image;
            if (LL_iPhoneX) {
                image = [UIImage imageNamed:@"用户引导-2-X"];
            }else{
                image = [UIImage imageNamed:@"用户引导-2"];
            }
            self.NewUserView.image = image;
            
        }else if (newUserCount == 2){
            UIImage *image;
            if (LL_iPhoneX) {
                image = [UIImage imageNamed:@"用户引导-3-X"];
            }else{
                image = [UIImage imageNamed:@"用户引导-3"];
            }
            self.NewUserView.image = image;
            
        }else if (newUserCount == 3){
            UIImage *image;
            if (LL_iPhoneX) {
                image = [UIImage imageNamed:@"用户引导-4-X"];
            }else{
                image = [UIImage imageNamed:@"用户引导-4"];
            }
            self.NewUserView.image = image;
            
        }else{
            [self.jmHoledView removeFromSuperview];
        }
        
        
        
        
        
    }
}

- (UIView *)viewForDemo
{
    UIImage *image;
    
    if (LL_iPhoneX) {
        image = [UIImage imageNamed:@"用户引导-1-X"];
    }else{
        image = [UIImage imageNamed:@"用户引导-1"];
    }
    self.NewUserView = [[UIImageView alloc] initWithImage:image];
    self.NewUserView.frame = launchScrollView.frame;
    return self.NewUserView;
    
    
    
}


- (UIView *)clickForView
{
    
    UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"用户引导按钮"]];
    v.frame = CGRectMake((kWidth-150*kScale)/2, 200*kScale, 150*kScale, 43*kScale);
    return v;
    
    
    
}

-(JMHoledView *)jmHoledView{
    if (!_jmHoledView) {
        _jmHoledView = [[JMHoledView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
        _jmHoledView.holeViewDelegate = self;
        
    }
    return _jmHoledView;
}










@end
