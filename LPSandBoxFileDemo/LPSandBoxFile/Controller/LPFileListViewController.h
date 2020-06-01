//
//  LPFileListViewController.h
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPFileListViewController : UITableViewController

/**
 *  起始路径,默认为root
 */
@property (nonatomic, copy) NSString *basePath;

/**
 *  是否是第一级
 */
@property (nonatomic, assign) BOOL isBaseVC;

@end

NS_ASSUME_NONNULL_END
