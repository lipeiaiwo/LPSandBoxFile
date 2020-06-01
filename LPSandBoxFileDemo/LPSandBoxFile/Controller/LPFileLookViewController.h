//
//  LPFileLookViewController.h
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import <QuickLook/QuickLook.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPFileLookViewController : QLPreviewController

@property (nonatomic, copy) NSString *filePath;

@end

NS_ASSUME_NONNULL_END
