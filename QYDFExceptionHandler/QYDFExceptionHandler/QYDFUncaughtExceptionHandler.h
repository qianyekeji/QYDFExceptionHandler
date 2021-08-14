//
//  QYDFUncaughtExceptionHandler.h
//  QYDFExceptionHandler
//
//  Created by xiaoyang on 2021/8/3.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "QYDFLogViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QYDFUncaughtExceptionHandler : NSObject<LogVCDelegate>{
    BOOL dismissed;
}
@property (nonatomic, strong)UIViewController *vc;
@property (nonatomic, strong)QYDFLogViewController *lvc;
@property (nonatomic, copy)NSString *logStr;
@end
void HandleException(NSException *exception);
void SignalHandler(int signal);


void InstallQYDFUncaughtExceptionHandler(void);

NS_ASSUME_NONNULL_END
