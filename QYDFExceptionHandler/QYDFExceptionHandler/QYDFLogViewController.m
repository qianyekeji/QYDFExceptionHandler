//
//  QYDFLogViewController.m
//  QYDFExceptionHandler
//
//  Created by xiaoyang on 2021/8/3.
//

#import "QYDFLogViewController.h"
#import "UIImage+QYDFImageWaterPrint.h"
#import "UIView+WaterMark.h"

@interface QYDFLogViewController ()

@end

@implementation QYDFLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgView=self.view;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    //添加 设备旋转 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    // Do any additional setup after loading the view.
}
-(void)orientChange:(NSNotification *)noti{
    self.bgView.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _logView =[[UIView alloc]initWithFrame:CGRectMake(0, 100, self.bgView.bounds.size.width-20, self.bgView.bounds.size.height-200)];
    _logContentView =[[UITextView alloc]initWithFrame:CGRectMake(10, 10, self.logView.bounds.size.width-20, self.logView.bounds.size.height-100)];
}
-(UIView *)logView
{
    if (!_logView) {
        _logView =[[UIView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width-20, self.view.bounds.size.height-200)];
        _logView.center=self.view.center;
        _logView.backgroundColor=[UIColor colorWithWhite:1 alpha:0.5];
        _logView.alpha=1;
        _logView.clipsToBounds=YES;
    }
    return _logView;
}
-(UITextView *)logContentView
{
    if (!_logContentView) {
        _logContentView =[[UITextView alloc]initWithFrame:CGRectMake(10, 10, self.logView.bounds.size.width-20, self.logView.bounds.size.height-100)];
        _logContentView.backgroundColor=[UIColor clearColor];
        _logContentView.editable=NO;
        _logContentView.textColor=[UIColor blackColor];
        _logContentView.font=[UIFont boldSystemFontOfSize:10];
    }
    return _logContentView;
}
-(void)showLog:(BOOL)log{
    if (log) {
        self.logContentView.text=self.logInputStr;
        [self.bgView addSubview:self.logView];
        //添加背景图
        UIImage *image = [UIImage imageNamed:@"bg.jpeg"];
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        layer.contents = (__bridge id _Nullable)(image.CGImage);

        //[self.logView.layer addSublayer:layer];
        [self.logView addSubview:self.logContentView];
        [self.logView addSubview:self.saveLog2PhotoBtn];
        [self.logView addSubview:self.cancelLogBtn];
        //添加水印
        [self.view addWaterMarkText:@"千叶豆腐" WithTextColor:[UIColor redColor] WithFont:[UIFont systemFontOfSize:9]];
        
    }
    
}
-(UIButton *)saveLog2PhotoBtn{
    if (!_saveLog2PhotoBtn) {
        _saveLog2PhotoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_saveLog2PhotoBtn setTitle:@"保 存" forState:UIControlStateNormal];
        _saveLog2PhotoBtn.frame=CGRectMake(self.logView.bounds.size.width/2-120, self.logView.bounds.size.height-100, 100, 44);
        _saveLog2PhotoBtn.layer.masksToBounds=YES;
        _saveLog2PhotoBtn.layer.cornerRadius=10;
        _saveLog2PhotoBtn.layer.borderColor=[UIColor blueColor].CGColor;
        _saveLog2PhotoBtn.layer.borderWidth = 2.0f;
        
       
        [_saveLog2PhotoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_saveLog2PhotoBtn addTarget:self action:@selector(save2Img) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveLog2PhotoBtn;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.logContentView.editable) {
        [self.logContentView endEditing:YES];
    }
}
-(UIButton *)cancelLogBtn{
    if (!_cancelLogBtn) {
        _cancelLogBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _cancelLogBtn.frame=CGRectMake(self.logView.bounds.size.width/2+20, self.logView.bounds.size.height-100, 100, 44);
        [_cancelLogBtn setTitle:@"取 消" forState:UIControlStateNormal];
        _cancelLogBtn.layer.masksToBounds=YES;
        _cancelLogBtn.layer.cornerRadius=10;
        _cancelLogBtn.layer.borderColor=[UIColor blueColor].CGColor;
        _cancelLogBtn.layer.borderWidth = 2.0f;
        [_cancelLogBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_cancelLogBtn addTarget:self action:@selector(cancelImg) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelLogBtn;
}
-(void)save2Img{
    //生成图片
    UIImage *img=[self makeImageWithView:self.logContentView withSize:self.logContentView.bounds.size];
    //保存到相册
    UIImageWriteToSavedPhotosAlbum(img, nil, @selector(saveOK), nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate&&[self.delegate respondsToSelector:@selector(SaveLog2Photo:)]) {
            [self.delegate SaveLog2Photo:self.logContentView.text];
        }
        });

    
}

#pragma mark 生成image
- (UIImage *)makeImageWithView:(UIView *)view withSize:(CGSize)size
{
    
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数 [UIScreen mainScreen].scale。
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
 
}
-(void)cancelImg{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(CancelLog)]) {
        [self.delegate CancelLog];
    }
}
#pragma mark -- <保存到相册>
-(void)saveOK{
    NSLog(@"baocun------------");
}
-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil
         ];
        
        
        //结束 设备旋转通知
        [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
