//
//  LPSandBoxFile.m
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import "LPSandBoxFile.h"
#import "LPFileListViewController.h"

@implementation LPSandBoxFile

+ (void)pushSandBoxFileWithVC:(UIViewController *)vc
{
    [self pushSandBoxFileWithVC:vc basePath:@""];
}

+ (void)pushSandBoxFileWithVC:(UIViewController *)vc basePath:(NSString *)basePath
{
    [self jumpFileListVCWithVC:vc basePath:basePath isPush:YES];
}

+ (void)presentSandBoxFileWithVC:(UIViewController *)vc
{
    [self presentSandBoxFileWithVC:vc basePath:@""];
}

+ (void)presentSandBoxFileWithVC:(UIViewController *)vc basePath:(NSString *)basePath
{
    [self jumpFileListVCWithVC:vc basePath:basePath isPush:NO];
}

+ (void)jumpFileListVCWithVC:(UIViewController *)vc basePath:(NSString *)basePath isPush:(BOOL)isPush
{
    LPFileListViewController *fileListVC = [[LPFileListViewController alloc] init];
    
    if (basePath.length) {
        
        fileListVC.basePath = basePath;
    }
    
    if (isPush) {
        
        [vc.navigationController pushViewController:fileListVC animated:YES];
    }else{
        
        fileListVC.isBaseVC = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:fileListVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [vc presentViewController:nav animated:YES completion:nil];
    }
}




@end
