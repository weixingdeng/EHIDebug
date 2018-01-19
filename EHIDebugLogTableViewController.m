//
//  EHIDebugLogTableViewController.m
//  调试
//
//  Created by dengwx on 2017/6/9.
//  Copyright © 2017年 Ehi. All rights reserved.
//

#import "EHIDebugLogTableViewController.h"

@interface EHIDebugLogTableViewController ()<UIDocumentInteractionControllerDelegate>

@property (nonatomic , strong) NSMutableArray *logArray;

@end

@implementation EHIDebugLogTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"调试日志";
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"崩溃日志" style:UIBarButtonItemStyleDone target:self action:@selector(showCrashInfo)];
    [self getAlllogFile];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//显示崩溃信息
- (void)showCrashInfo
{
    NSString *path = [[self creatDirectoryWithName:@"Crash"] stringByAppendingPathComponent:@"ExceptionInfo.txt"];
    
    [self showDocumentWithPath:path];

}

//获取所有调试日志
- (void)getAlllogFile
{
    NSString *path = [self creatDirectoryWithName:@"Log"];
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator = [myFileManager enumeratorAtPath:path];
    
    while((path = [myDirectoryEnumerator nextObject]) != nil)
    {
        
        [self.logArray addObject:path];
    }
    [self.logArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    [self.tableView reloadData];
    
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.logArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//创建目录
- (NSString *)creatDirectoryWithName:(NSString *)directoryName
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.logArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.logArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *path = [[self creatDirectoryWithName:@"Log"] stringByAppendingPathComponent:self.logArray[indexPath.row]];
    [self showDocumentWithPath:path];

}

//显示文档信息
- (void)showDocumentWithPath:(NSString *)path
{
    UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];//为该对象初始化一个加载路径
    docController.delegate =self;//设置代理
    
    [docController presentPreviewAnimated:YES];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return  self.view.frame;
}

- (NSMutableArray *)logArray
{
    if (!_logArray) {
        
        _logArray = [[NSMutableArray alloc] init];
    }
    return _logArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
