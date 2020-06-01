//
//  LPFileLookViewController.h
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import "LPFileLookViewController.h"

@interface LPFileLookViewController ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>

@property (nonatomic, strong) QLPreviewController *qlVC;

@end

@implementation LPFileLookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
}

- (void)initData
{
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark QLPreviewControllerDataSource
// 返回文件的个数
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return self.filePath.length ? 1 : 0;
}

// 加载需要显示的文件
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
        
    return [NSURL fileURLWithPath:self.filePath];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
