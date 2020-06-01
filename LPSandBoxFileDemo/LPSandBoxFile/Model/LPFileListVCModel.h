//
//  LPFileListVCModel.h
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPFileListVCModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *path;

@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
