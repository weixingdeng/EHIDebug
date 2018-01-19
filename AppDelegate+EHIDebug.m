//
//  AppDelegate+EHIDebug.m
//  调试
//
//  Created by dengwx on 2017/6/9.
//  Copyright © 2017年 Ehi. All rights reserved.
//

#import "AppDelegate+EHIDebug.h"
#import "EHIDebugLogManager.h"
#import "EHIDebugCrashManaget.h"
#import "EHIDebugEnvironment.h"

@implementation AppDelegate (EHIDebug)

#ifdef DEBUG

+ (void)load {
    // 收集调试日志
    [EHIDebugLogManager startDebugLog];
    
    // 手机崩溃日志
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

#endif


@end
