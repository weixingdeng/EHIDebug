//
//  EHICrashManaget.h
//  DebugTools
//
//  Created by dengwx on 2017/12/4.
//  Copyright © 2017年 Ehi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHIDebugCrashManaget : NSObject

void UncaughtExceptionHandler(NSException* exception);

@end
