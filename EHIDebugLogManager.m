//
//  EHIDebugLogManager.m
//  Test
//
//  Created by dengwx on 2017/5/25.
//  Copyright © 2017年 Ehi. All rights reserved.
//

#import "EHIDebugLogManager.h"
#import "EHIDebugLogServer.h"

@implementation EHIDebugLogManager

+ (void)startDebugLog
{
    //如果是模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        
        NSLog(@"是模拟器");
        return;
    }
    
    //如果连接xcode
    if (isatty(STDOUT_FILENO)) {
        
        NSLog(@"连着xcode");
        return;
    }
    
    [self logToLocalFile];
    
}

//输出日志到本地
+ (void)logToLocalFile
{
    NSString *logPath = [self creatDirectoryWithName:@"Log"];
    //创建日志文件
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFileName = [NSString stringWithFormat:@"%@.txt",dateStr];
    NSString *logFilePath = [logPath stringByAppendingPathComponent:logFileName];
    
    //将缓冲区禁止
    setvbuf(stdout,NULL,_IONBF,0);
    //用创建的文件描述符替换掉 标准输出和错误输出
    int fd = open([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],(O_RDWR | O_CREAT), 0644);
    dup2(fd,STDOUT_FILENO);
//    dup2(fd, STDERR_FILENO);
    
    /** 添加文件改变监控 */
    [EHIDebugLogServer setupFileObserveWithPath:logFilePath];
}


//创建目录
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

@end
