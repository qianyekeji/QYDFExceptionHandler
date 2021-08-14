//
//  UIViewController+ExcepitionHandler.h
//  bengkui
//
//  Created by xiaoyang on 2021/8/3.
//  Copyright © 2021 rainbird. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ExcepitionHandler) {}
+ (UIViewController *)findCurrentShowingViewController;
+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc;
@end
NS_ASSUME_NONNULL_END
