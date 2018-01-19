//
//  EHIDebugHomeTableViewController.m
//  DebugTools
//
//  Created by dengwx on 2017/12/4.
//  Copyright © 2017年 Ehi. All rights reserved.
//

#import "EHIDebugHomeTableViewController.h"
#import "EHIDebugEnvironment.h"
#import "EHIDebugLogTableViewController.h"
#import "EHIDebugLogServer.h"
#import <FLEXManager.h>

@interface EHIDebugHomeTableViewController ()

@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) NSMutableArray *vcArray;

@end

@implementation EHIDebugHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"调试信息";
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 || indexPath.row == 1) {
        
        EHIDebugLogTableViewController *viewController = [EHIDebugLogTableViewController new];
        UIBarButtonItem *customLeftBarButtonItem = [[UIBarButtonItem alloc] init];
        customLeftBarButtonItem.title = @"返回";
        self.navigationItem.backBarButtonItem = customLeftBarButtonItem;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    // 切换网络环境
    if (indexPath.row == 2) {
        
        [EHIDebugEnvironment changeEnvironment];
        return;
    }
    
    if (indexPath.row == 3) {
        
        NSString * urlStr = @"App-Prefs:root";
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
           
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
            }
          
        }
    }
    if (indexPath.row == 4) {
        [self presentViewController:[EHIDebugLogServer showAlertWithcompletion:^{
            
            [self.titleArray setObject:[EHIDebugLogServer getSocket] atIndexedSubscript:4];
            [self.tableView reloadData];
            
        }] animated:YES completion:nil];
    }
    
    if (indexPath.row == 5) {
        
        [[FLEXManager sharedManager] showExplorer];
    }
//    UIViewController* viewController  = [[NSClassFromString([self.vcArray objectAtIndex:indexPath.row]) alloc] init];
//
//    viewController.title = [self.titleArray objectAtIndex:indexPath.row];
//    UIBarButtonItem *customLeftBarButtonItem = [[UIBarButtonItem alloc] init];
//    customLeftBarButtonItem.title = @"返回";
//    self.navigationItem.backBarButtonItem = customLeftBarButtonItem;
//    [self.navigationController pushViewController:viewController animated:YES];
}

- (NSMutableArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = [NSMutableArray arrayWithObjects:
                       @"调试日志",
                       @"崩溃信息",
                       @"切换网络环境",
                       @"模拟网速(打开开发者模式)",
                       [EHIDebugLogServer getSocket],
                       @"FLEX调试工具",
                       
                       nil];
    }
    return _titleArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
