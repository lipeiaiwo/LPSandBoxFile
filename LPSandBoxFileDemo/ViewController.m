//
//  ViewController.m
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import "ViewController.h"
#import "LPSandBoxFile.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self initUI];
    
    [self jumpSandBoxFile];
}

- (void)initUI
{
    // 去除返回键文字
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    self.view.backgroundColor = UIColor.orangeColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self jumpSandBoxFile];
}

- (void)jumpSandBoxFile
{
    [LPSandBoxFile pushSandBoxFileWithVC:self];
}

@end
