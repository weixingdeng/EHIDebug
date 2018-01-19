//
//  EHIDebugLogServer.h
//  1haiiPhone
//
//  Created by 杨明鑫 on 2017/12/5.
//  Copyright © 2017年 EHi. All rights reserved.
//
//  开启web服务，通过打开浏览器输入手机ip地址和端口8080访问本次日志。
//  两个以上浏览器同时访问还是有一点小问题。。。。
//

#import <Foundation/Foundation.h>
typedef void(^Callback)(void) ;
@interface EHIDebugLogServer : NSObject

/** 开启服务 */
+ (BOOL)startServer;

/** 关闭服务 */
+ (BOOL)closeServer;

/** 获取当前手机套接字 */
+ (NSString *)getSocket;

/** 返回UIAlert弹框提示开关网络 */
+ (UIAlertController *) showAlertWithcompletion:(Callback)callback;

/** 监听文件变化 */
+ (void)setupFileObserveWithPath:(NSString *)path;

@end
