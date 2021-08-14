//
//  QYDFUncaughtExceptionHandler.m
//  QYDFExceptionHandler
//
//  Created by xiaoyang on 2021/8/3.
//

#import "QYDFUncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "QYDFApp.h"
#import "UIViewController+ExcepitionHandler.h"
#import <AudioToolbox/AudioToolbox.h>


NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation QYDFUncaughtExceptionHandler



+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}
-(void)SaveLog2Photo:(NSString *)str{
    dispatch_async(dispatch_get_main_queue(), ^{
        //把错误信息保存到本地文件，设置errorLogPath路径下
        NSString * logPath  = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"CrashLogs"];
        //并且经试验，此方法写入本地文件有效。
        if (![[NSFileManager defaultManager] fileExistsAtPath:logPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:logPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSString *crashDate = [formatter stringFromDate:[NSDate date]];
        NSString *errorLogPath = [NSString stringWithFormat:@"%@/%@/", logPath,crashDate];
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:errorLogPath]) {
            [manager createDirectoryAtPath:errorLogPath withIntermediateDirectories:true attributes:nil error:nil];
        }
        [formatter setDateFormat:@"HH-mm-ss"];
        NSString *crashTimeStr = [formatter stringFromDate:[NSDate date]];
        errorLogPath = [errorLogPath stringByAppendingFormat:@"%@.log",crashTimeStr];
        
        NSError *error = nil;
        
        NSLog(@"日志保存路径：%@", errorLogPath);
        BOOL isSuccess = [str writeToFile:errorLogPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!isSuccess) {
            NSLog(@"将crash信息保存到本地失败: %@", error.userInfo);
            
        }
        self->dismissed = NO;
        [self.lvc dismissViewControllerAnimated:YES completion:nil];
        
    });
    
}
-(void)CancelLog{
    self->dismissed = NO;
    [self.lvc dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)validateAndSaveCriticalApplicationData
{
    
    
}

- (void)handleException:(NSException *)exception
{
    [self validateAndSaveCriticalApplicationData];
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *crashTime = [formatter stringFromDate:[NSDate date]];
    self.logStr= [NSString stringWithFormat:@"%@%@CrashTime: %@\nException reason: %@\nException name: %@\nException call stack:%@\n",[QYDFApp getAppInfo],[QYDFApp getDeviceInfo], crashTime, [exception name], [exception reason], [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    UIViewController *vc=[UIViewController findCurrentShowingViewController];
    self.lvc=[[QYDFLogViewController alloc]init];
    self.lvc.delegate=self;
    self.lvc.logInputStr=self.logStr;
    [self.lvc showLog:YES];
    self.lvc.modalPresentationStyle=UIModalPresentationOverFullScreen;
    
    // self.lvc.modalPresentationStyle=UIModalPresentationOverFullScreen;
    //[self.lvc showLog:[NSString stringWithFormat:
    //                                                             @"%@%@您可以尝试继续，但应用程序可能不稳定.\n\n"
    //                                                             @"问题日志如下:\n%@\n%@",[QYDFApp getAppInfo],[QYDFApp getDeviceInfo],
    //                                                             [exception reason],
    //                  [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]]];
    
    [vc presentViewController:self.lvc animated:YES completion:^{AudioServicesPlaySystemSound(1334);}];
    //    UIAlertView *alert =
    //        [[[UIAlertView alloc]
    //            initWithTitle:NSLocalizedString(@"Unhandled exception", nil)
    //            message:[NSString stringWithFormat:NSLocalizedString(
    //                @"You can try to continue but the application may be unstable.\n\n"
    //                @"Debug details follow:\n%@\n%@", nil),
    //                [exception reason],
    //                [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]]
    //            delegate:self
    //            cancelButtonTitle:NSLocalizedString(@"Quit", nil)
    //            otherButtonTitles:NSLocalizedString(@"Continue", nil), nil]
    //        autorelease];
    //    [alert show];
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed)
    {
        for (NSString *mode in (__bridge NSArray *)allModes)
        {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
}

@end

void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSArray *callStack = [QYDFUncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[QYDFUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
         [NSException
          exceptionWithName:[exception name]
          reason:[exception reason]
          userInfo:userInfo]
     waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableDictionary *userInfo =
    [NSMutableDictionary
     dictionaryWithObject:[NSNumber numberWithInt:signal]
     forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [QYDFUncaughtExceptionHandler backtrace];
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[QYDFUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
         [NSException
          exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
          reason:
              [NSString stringWithFormat:
               @"Signal %d was raised.",
               signal]
          userInfo:
              [NSDictionary
               dictionaryWithObject:[NSNumber numberWithInt:signal]
               forKey:UncaughtExceptionHandlerSignalKey]]
     waitUntilDone:YES];
}

void InstallQYDFUncaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}


