//
//  QYDFLogViewController.h
//  QYDFExceptionHandler
//
//  Created by xiaoyang on 2021/8/3.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LogVCDelegate <NSObject>
@optional
-(void)SaveLog2Photo:(NSString *)str;
-(void)CancelLog;

@end
@interface QYDFLogViewController : UIViewController
@property (nonatomic,strong)UIView *logView;
@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UITextView *logContentView;
@property (nonatomic,strong)UITextField *addLogView;
@property (nonatomic,strong)UIButton *saveLog2PhotoBtn;
@property (nonatomic,strong)UIButton *cancelLogBtn;
@property (nonatomic,copy)NSString *logInputStr;
@property (nonatomic, weak)id <LogVCDelegate> delegate;
-(void)showLog:(BOOL)log;
@end

NS_ASSUME_NONNULL_END
