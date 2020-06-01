//
//  LPFileListVCCell.h
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPFileListVCModel.h"

NS_ASSUME_NONNULL_BEGIN

#define LPFileListVCCellH 70

@interface LPFileListVCCell : UITableViewCell

@property (nonatomic, strong) LPFileListVCModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
