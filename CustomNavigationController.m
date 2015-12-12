//
//  CustomNavigationController.m
//  TEST
//
//  Created by 朱大茂 on 15/11/12.
//  Copyright (c) 2015年 zhudm. All rights reserved.
//


#import "CustomNavigationController.h"

#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height

#define startX 150.0f

@interface CustomNavigationController ()<UIGestureRecognizerDelegate>
{
    CGPoint startTouch;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) UIView *blackMask;
@property (nonatomic, retain) UIImageView * lastScreenShotView;
@property (nonatomic, retain) UIView * topCtrlView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;

@end

@implementation CustomNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.canDragBack = YES;
    }
    return self;
}

/**
 *  fix the when use storyBoard
 *
 *  @param aDecoder
 *
 *  @return id
 */

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.canDragBack = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //屏蔽掉iOS7以后自带的滑动返回手势 否则有BUG
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
        self.interactivePopGestureRecognizer.delegate = nil;
    }
    
    self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];

    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(paningGestureReceive:)];
    recognizer.delaysTouchesBegan = YES;
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.screenShotsList addObject:[self capture]];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
    [self.screenShotsList removeAllObjects];
    
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark - Private Method

- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

/**
 *  根据 x 改变self.view 的frame
 *
 *  @param x
 */
- (void)moveViewWithX:(float)x
{
    if (x < 0) {
        return;
    }
    
    float balpha = x < 0 ? -x : x;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(x, 0);

    [self.view setTransform:transform];
    
    float alpha = 0.5 - (balpha/800);
    self.blackMask.alpha = alpha;
}

/**
 *  和 self.view 平级，放在window 上，放在self.view 下面
 *
 *  @return <#return value description#>
 */
- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(-kDeviceWidth*0.9 , 0, kDeviceWidth , kDeviceHeight)];
        [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
        
        [self.backgroundView addSubview:self.blackMask];
    }

    return _backgroundView;
}

- (UIView *)blackMask{
    if (!_blackMask) {
        _blackMask = [[UIView alloc]initWithFrame:self.backgroundView.bounds];
        _blackMask.backgroundColor = [UIColor blackColor];
    }

    return _blackMask;
}

- (UIImageView *)lastScreenShotView{
    if (!_lastScreenShotView) {
        _lastScreenShotView = [[UIImageView alloc] initWithFrame:self.backgroundView.bounds];
        [self.backgroundView insertSubview:_lastScreenShotView belowSubview:self.blackMask];
    }
    
    return _lastScreenShotView;
}

#pragma mark - Gesture Recognizer -
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        startTouch = touchPoint;
        self.backgroundView.hidden = NO;
        self.lastScreenShotView.image = [self.screenShotsList lastObject];
        
    }else if (UIGestureRecognizerStateChanged == recoginzer.state ){
        CGPoint touch = [recoginzer locationInView:KEY_WINDOW];
        CGFloat chaValue = touch.x - startTouch.x;
        [self moveViewWithX:chaValue];
        
        chaValue *= 0.9;
        if (chaValue > kDeviceWidth *0.9 || chaValue <0) {
            return;
        }
        self.backgroundView.transform = CGAffineTransformMakeTranslation(chaValue, 0);
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > startX)
        {
            [self pop];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.backgroundView.transform = CGAffineTransformIdentity;
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
    }else if (UIGestureRecognizerStateCancelled == recoginzer.state){
        
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundView.transform = CGAffineTransformIdentity;
            [self moveViewWithX:0];
            
        } completion:^(BOOL finished) {
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
}

- (void)pop
{
    [UIView animateWithDuration:0.4 animations:^{
        [self moveViewWithX:kDeviceWidth];
        self.backgroundView.transform = CGAffineTransformMakeTranslation(0.9*kDeviceWidth, 0);
    } completion:^(BOOL finished){
        [self popViewControllerAnimated:NO];
        self.view.transform = CGAffineTransformIdentity;
        self.backgroundView.transform = CGAffineTransformIdentity;
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.viewControllers.count <= 1 || !self.canDragBack)
        return NO;
    return YES;
}

#pragma mark -Memhandle
- (void)dealloc
{
    self.screenShotsList = nil;
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}

@end

