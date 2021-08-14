//
//  QYDFApp.h
//  QYDFApp
//
//  Created by xiaoyang on 2021/8/4.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QYDFApp : NSObject
+(NSString*) getLocalAppVersion;
+(NSString*) getBundleID;
+(NSString*) getAppName;
+(NSString*) getDeviceInfo;
+(NSString*) getAppInfo;
+(NSString *)getPhoneModel;
@end

NS_ASSUME_NONNULL_END
