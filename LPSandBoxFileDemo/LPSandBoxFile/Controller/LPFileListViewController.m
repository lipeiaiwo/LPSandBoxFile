//
//  LPFileListViewController.m
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import "LPFileListViewController.h"
#import "LPFileListVCCell.h"
#import "LPFileLookViewController.h"
#import "GCDWebUploader.h"

@interface LPFileListViewController ()

@property (nonatomic, strong) NSMutableArray *cellModelAry;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation LPFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self getData];
}

- (void)initUI
{
    self.tableView.rowHeight = LPFileListVCCellH;
    
    self.navigationItem.title = _basePath ? [_basePath lastPathComponent] : @"/";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"WiFi互传" style:UIBarButtonItemStylePlain target:self action:@selector(openWiFiFile)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14],NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    if (self.isBaseVC) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(clickClose)];
    }
    
    // 去除返回键文字
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
}

- (void)getData
{
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.basePath ?: NSHomeDirectory() error:nil];
    
    // 排序
    fileList = [fileList sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    
    for (NSString *fileName in fileList) {
        
        LPFileListVCModel *model = [[LPFileListVCModel alloc] init];
        model.title = fileName;
        model.path = [self.basePath stringByAppendingPathComponent:fileName];
        [self.cellModelAry addObject:model];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellModelAry.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPFileListVCCell *cell = [LPFileListVCCell cellWithTableView:tableView];
    
    cell.model = self.cellModelAry[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 防止有时候 延迟触摸响应
    dispatch_async(dispatch_get_main_queue(), ^{
        
        LPFileListVCModel *model = self.cellModelAry[indexPath.row];
        
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:model.path isDirectory:&isDirectory];
        
        if (isDirectory) {
            
            // 是文件夹
            LPFileListViewController *vc = [[LPFileListViewController alloc] init];
            vc.basePath = model.path;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
            // 是文件
            [self operationFileModel:model];
        }
    });
}

#pragma mark 左滑显示删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LPFileListVCModel *model = self.cellModelAry[indexPath.row];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager removeItemAtPath:model.path error:nil]) {
            
            [self.cellModelAry removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }else{
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"删除失败" preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
            
            [alertController addAction:cancelAction];
                
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    return @[deleteAction];
}

- (void)operationFileModel:(LPFileListVCModel *)model
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *airDropAction = [UIAlertAction actionWithTitle:@"AirDrop发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showDocumentWithModel:model];
    }];
    
    UIAlertAction *readAction = [UIAlertAction actionWithTitle:@"直接阅读" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self readLogsWithModel:model];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:airDropAction];
    [alertController addAction:readAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 *  显示AirDrop 发送文件
 */
- (void)showDocumentWithModel:(LPFileListVCModel *)model
{
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:model.path]];
    [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}


/**
 *  直接读 文件
 */
- (void)readLogsWithModel:(LPFileListVCModel *)model
{
    LPFileLookViewController *lookVC = [[LPFileLookViewController alloc] init];
    lookVC.filePath = model.path;
    [self.navigationController pushViewController:lookVC animated:YES];
}

- (void)openWiFiFile
{
    GCDWebUploader *webServer = [[GCDWebUploader alloc] initWithUploadDirectory:self.basePath];
    
    webServer.prologue = @"请保持手机APP停留在弹窗界面,不要关掉APP弹窗界面,切换APP或者退出到桌面和锁屏";

    if ([webServer startWithPort:8080 bonjourName:@"Web Based Uploads"]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"请在电脑浏览器里面输入以下任一地址\n%@\n%@\n上传过程中请勿关闭该弹窗或者离开该界面和锁屏",webServer.bonjourServerURL,webServer.serverURL] preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我已传输完毕,关掉WiFi传输" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                [webServer stop];
            }];
            
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            NSLog(@"\n地址1:%@ \n地址2:%@",webServer.bonjourServerURL,webServer.serverURL);
        });
    }
}

- (void)clickClose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)basePath
{
    return _basePath.length ? _basePath : NSHomeDirectory();
}


- (NSMutableArray *)cellModelAry
{
    if (!_cellModelAry) {
        _cellModelAry = [NSMutableArray array];
    }
    
    return _cellModelAry;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
