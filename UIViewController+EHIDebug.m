//
//  UIViewController+EHIDebug.m
//  调试
//
//  Created by dengwx on 2017/6/9.
//  Copyright © 2017年 Ehi. All rights reserved.
//

#import "UIViewController+EHIDebug.h"

@implementation UIViewController (EHIDebug)

#ifdef DEBUG

//摇一摇
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    UIViewController *pushView = [[NSClassFromString(@"EHIDebugHomeTableViewController") alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pushView];
    
    [self presentViewController:nav animated:YES completion:nil];
}


#endif


@end
