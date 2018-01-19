//
//  EHIDebugEnvironment.m
//  1haiiPhone
//
//  Created by 杨明鑫 on 2017/11/29.
//  Copyright © 2017年 EHi. All rights reserved.
//

#import "EHIDebugEnvironment.h"
#import "UserContext.h" // 业务侵入(使用请移除)
//enum ENVIRONMENT{
//    ENVIRONMENT_PRODUCTION,
//    ENVIRONMENT_DEMO,
//    ENVIRONMENT_DEVELOPMENT,
//} ;

@implementation EHIDebugEnvironment

/** 切换事件 */
+ (void)changeEnvironment {
    
    NSString *currentEnvironmentStr = nil;
    enum ENVIRONMENT current =  (enum ENVIRONMENT)[[NSUserDefaults standardUserDefaults] integerForKey:@"ENVIRONMENT"];
    switch (current) {
        case ENVIRONMENT_PRODUCTION:
            currentEnvironmentStr = @"当前为：PRODUCTION环境";
            break;
        case ENVIRONMENT_DEMO:
            currentEnvironmentStr = @"当前为：DEMO环境";
            break;
        case ENVIRONMENT_DEVELOPMENT:
            currentEnvironmentStr = @"当前为：DEVELOPMENT环境";
            break;
            
        default:
            break;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:currentEnvironmentStr message:@"请注意APP当前环境，如不正确请切换" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *productionAction = [UIAlertAction actionWithTitle:@"PRODUCTION环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setInteger:ENVIRONMENT_PRODUCTION forKey:@"ENVIRONMENT"];
        [self restartHint];
        
    }];
    UIAlertAction *demoAction = [UIAlertAction actionWithTitle:@"DEMO环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setInteger:ENVIRONMENT_DEMO forKey:@"ENVIRONMENT"];
        [self restartHint];
    }];
    UIAlertAction *developmentAction = [UIAlertAction actionWithTitle:@"DEVELOPMENT环境" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setInteger:ENVIRONMENT_DEVELOPMENT forKey:@"ENVIRONMENT"];
        [self restartHint];
    }];
 
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:productionAction];
    [alert addAction:demoAction];
    [alert addAction:developmentAction];
    [alert addAction:cancel];
    
//    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
    
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];

    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
        
        // 此处主要考虑当前导航没有层次 如果之后还会push 请注释掉此处的return
        return rootVC;
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        // 此处为了加快遍历  可能会出问题 待看
        return currentVC;
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

/** 重启提示 */
+ (void)restartHint {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CHANGE_ENVIRONMENT"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"您已经切换了网络环境，为防止误操作，请重启APP" preferredStyle:UIAlertControllerStyleAlert];
    static int count = 0;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        count ++;
        if (count == 3) {
            count = 0;
            // 下次启动不切换环境 本次改变
            SHARE_USER_CONTEXT.urlList.environment = (enum ENVIRONMENT)[[NSUserDefaults standardUserDefaults] integerForKey:@"ENVIRONMENT"];
          
            return;
        }
        [self restartHint];
    }];
    
    UIAlertAction *reStart = [UIAlertAction actionWithTitle:@"重启APP" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        exit(0);
    }];
    
    [alert addAction:cancel];
    [alert addAction:reStart];
    
    [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
}

@end

