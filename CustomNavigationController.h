//
//  CustomNavigationController.h
//  TEST
//
//  Created by 朱大茂 on 15/11/12.
//  Copyright (c) 2015年 zhudm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define kkBackViewHeight [UIScreen mainScreen].bounds.size.height
#define kkBackViewWidth [UIScreen mainScreen].bounds.size.width

#define iOS7  ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

@interface CustomNavigationController : UINavigationController

// 默认为特效开启
@property (nonatomic, assign) BOOL canDragBack;

@end
