//
//  LPSandBoxFile.h
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPSandBoxFile : NSObject

/**
 *  push跳转方法 basePath默认为root路径
 */
+ (void)pushSandBoxFileWithVC:(UIViewController *)vc;

/**
 *  push跳转方法 basePath默认为root路径
 */
+ (void)pushSandBoxFileWithVC:(UIViewController *)vc basePath:(NSString *)basePath;


/**
 *  present跳转方法 basePath默认为root路径
 */
+ (void)presentSandBoxFileWithVC:(UIViewController *)vc;

/**
 *  present跳转方法 basePath默认为root路径
 */
+ (void)presentSandBoxFileWithVC:(UIViewController *)vc basePath:(NSString *)basePath;


@end

NS_ASSUME_NONNULL_END
