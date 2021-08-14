//
//  ViewController.m
//  QYDFExceptionHandler
//
//  Created by xiaoyang on 2021/8/3.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor greenColor];

    // Do any additional setup after loading the view.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.view.backgroundColor=[UIColor yellowColor];
    NSLog(@"崩溃了啊----");
  [self performSelector:@selector(qianyedoufu)];
}

@end
