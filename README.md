![icon](https://qianyedoufu.com/images/icon.png)
# QYDFExceptionHandler
你是否还在为APP闪退烦恼？是否被老板骂？现在我来啦！我来解决闪退问题，发生闪退的时候，APP不闪退。还可以闪退日志可以保存相册，随时随地查看。
---
## 效果展示
![QQ2021](https://qianyedoufu.com/images/QQ2021.gif)
## 使用方法
```
代码
在AppDelegate.m文件中引入
#import "QYDFUncaughtExceptionHandler.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //加入这一行代码
    InstallQYDFUncaughtExceptionHandler();

    return YES;
}
```
## 完，版权归属@[千业科技](https://qianyedoufu.com/web/index.html)
