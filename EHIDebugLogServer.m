//
//  EHIDebugLogServer.m
//  1haiiPhone
//
//  Created by 杨明鑫 on 2017/12/5.
//  Copyright © 2017年 EHi. All rights reserved.
//

#import "EHIDebugLogServer.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "MonitorFileChangeUtils.h"

static EHIDebugLogServer *shareInstance = nil;
static NSTimeInterval TIMEOUT = 18;   // 自动刷新请求超时设置
static NSString *REFRESH_TIME = @"100"; // 接收请求再次请求间隔时间(毫秒)
@interface EHIDebugLogServer()

/** web服务 */
@property (nonatomic, strong) GCDWebServer *server;

/** 线程信号量操作 */
@property (nonatomic, strong) NSCondition *condition;

/** 文件修改监控 */
@property (nonatomic, strong) MonitorFileChangeUtils *fileObserve;

/** 存储访问的IP地址 */
@property (nonatomic, strong) NSMutableDictionary *IPDictionary;

@end

@implementation EHIDebugLogServer

#ifdef DEBUG
+ (void)load {
    shareInstance = [[EHIDebugLogServer alloc] init];
    [shareInstance setup];
    // 默认开启
    [EHIDebugLogServer startServer];
}
#endif

+ (BOOL)startServer {
    if ([shareInstance.server isRunning]) {
        return NO;
    }
    // Start server on port 8080
    BOOL successed = [shareInstance.server startWithPort:8080 bonjourName:nil];
    NSLog(@"开启WEB服务：%@", successed ? @"成功" : @"失败");
    NSLog(@"Visit %@ in your web browser", shareInstance.server.serverURL);
    return successed;
}

+ (BOOL)closeServer {
    if (![shareInstance.server isRunning]) {
        return NO;
    }
    [shareInstance.server stop];
    NSLog(@"关闭WEB服务~~");
    return NO;
}

/** 获取全部日志文件 */
+ (NSMutableArray *)getAlllogFile
{
    NSString *path = [EHIDebugLogServer creatDirectoryWithName:@"Log"];
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator = [myFileManager enumeratorAtPath:path];
    NSMutableArray *logFiles = [NSMutableArray array];
    
    while((path = [myDirectoryEnumerator nextObject]) != nil)
    {
        
        [logFiles addObject:[[EHIDebugLogServer creatDirectoryWithName:@"Log"] stringByAppendingPathComponent:path]];
    }
    [logFiles sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    return logFiles;
}

/** 创建目录 */
+ (NSString *)creatDirectoryWithName:(NSString *)directoryName
{
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directoryPath = [[docPath objectAtIndex:0] stringByAppendingPathComponent:directoryName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:directoryPath];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:directoryPath  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return directoryPath;
}

/** 监听文件变化 */
+ (void)setupFileObserveWithPath:(NSString *)path {
    
    typeof(shareInstance) weakSelf = shareInstance;
    [shareInstance.fileObserve watcherForPath:path block:^(NSInteger type) {
        typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf.condition broadcast];
    }];
}

/** 返回套接字 */
+ (NSString *)getSocket {
    NSString *socket = [NSString stringWithFormat:@"%@", shareInstance.server.serverURL];
    // 如果服务没有开启会返回 (null)六个字符
    if (socket.length > 6) {
        return socket;
    } else {
        return @"暂未开启WEB服务";
    }
}

/** 返回UIAlert弹框提示开关网络,点击弹框以后会执行的操作 */
+ (UIAlertController *) showAlertWithcompletion:(Callback)callback {
    
    NSString *socketStr = [EHIDebugLogServer getSocket];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"开启网络提示" message:socketStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [EHIDebugLogServer closeServer];
        if (callback) {
            callback();
        }
    }];
    UIAlertAction *startAction = [UIAlertAction actionWithTitle:@"开启服务" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [EHIDebugLogServer startServer];
        if (callback) {
            callback();
        }
    }];
    
    [alert addAction:closeAction];
    [alert addAction:startAction];
    return alert;
}

/** 入口 */
- (void)setup {
    _IPDictionary = [NSMutableDictionary dictionary];
    _server = [[GCDWebServer alloc] init];
    __weak typeof(self) weakself = self;
    // 添加默认服务
    [_server addDefaultHandlerForMethod:@"GET"
                           requestClass:[GCDWebServerRequest class]
                           processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                               __strong typeof(self) strongself = weakself;
                               if ([strongself isFirstRequestWithAddress:request.remoteAddressString]) {
                                   return [GCDWebServerDataResponse responseWithHTML:strongself.getHtmlText];
                               }
                               // 长轮询,延时响应
                               [strongself.condition lock];
                               [strongself.condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:TIMEOUT] ];
                               [strongself.condition unlock];
                               return [GCDWebServerDataResponse responseWithHTML:strongself.getHtmlText];
                               
                           }];
    
}

/** 返回html文本 */
- (NSString *)getHtmlText {
    NSMutableArray *array = [EHIDebugLogServer getAlllogFile];
    NSString *string = @"暂无日志信息";
    NSString *title = @"日志信息";
    if (array.count) {
        
        string = [self getTextByFilePath:array.firstObject];
        title = [self getTextNameByFilePath:array.firstObject];
    }
    
    NSString *html = [NSString stringWithFormat:@"\
                      <!DOCTYPE html>\
                      <html>\
                      <head>\
                      <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\
                      <title>%@</title>\
                      <script>window.onload = function(){\
                      setTimeout(\"location=location; \", %@);\
                      \
                      } </script>\
                      </head>\
                      <body >\
                      <span >%@</span>\
                      \
                      </body>\
                      </html>\
                      \
                      ", title, REFRESH_TIME, string];
    return html;
}

/** 读取文本文件 */
- (NSString *)getTextByFilePath:(NSString *)path {
    NSError *error;
    NSString *string = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    string = [string  stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    //如果有报错，则把报错信息输出来
    if (error != nil) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return string;
}

/** 获取文件名 */
- (NSString *)getTextNameByFilePath:(NSString *)path {
    return [path componentsSeparatedByString:@"/"].lastObject;
}

/** 判断请求方IP是否是第一次请求 */
- (BOOL)isFirstRequestWithAddress:(NSString *)address {
    NSString *remoteAddress = [address componentsSeparatedByString:@":"].firstObject;
    if (![self.IPDictionary objectForKey:remoteAddress]) {
        [self.IPDictionary setObject:@"这个IP已经访问过" forKey:remoteAddress];
        return YES;
    }
    return NO;
}

#pragma mark - Getter

- (NSCondition *)condition {
    if (!_condition) {
        _condition = [[NSCondition alloc] init];
    }
    return _condition;
}

- (MonitorFileChangeUtils *)fileObserve {
    if (!_fileObserve) {
        _fileObserve = [[MonitorFileChangeUtils alloc] init];
    }
    return _fileObserve;
}

@end

