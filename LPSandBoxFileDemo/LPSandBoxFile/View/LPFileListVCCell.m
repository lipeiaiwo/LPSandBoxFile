//
//  LPFileListVCCell.m
//  LPSandBoxFileDemo
//
//  Created by lp on 2020/6/1.
//  Copyright © 2020 LP. All rights reserved.
//

#import "LPFileListVCCell.h"
#import <AVFoundation/AVFoundation.h>

#define gap 12
#define IconImageWH (LPFileListVCCellH - gap)

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ColorWihthRGB(R, G, B) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:1.0]
#define ColorWihthRGBA(R, G, B, A) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:A]


@interface LPFileListVCCell ()

@property (nonatomic, strong) UILabel *iconImageLabel;

@property (nonatomic, strong) UIImageView *iconImageV;

@property (nonatomic, strong) UIImageView *playImageV;

@property (nonatomic, strong) UILabel *titlelabel;

@property (nonatomic, strong) UILabel *detailsLabel;

@end

@implementation LPFileListVCCell

- (void)setModel:(LPFileListVCModel *)model
{
    _model = model;
    
    [self setIconImage];
    self.titlelabel.text = model.title;
    [self setDetailsLabelText];
}

- (void)setDetailsLabelText
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:self.model.path isDirectory:&isDirectory];
        
        if (isDirectory) {
            
            // 是文件夹
            NSString *str = [self folderSizeAtPath:self.model.path];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.detailsLabel.text = str;
            });
        } else {
            
            // 是文件
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *time = [self fileTimeAtPath:self.model.path];
                
                self.detailsLabel.text = [NSString stringWithFormat:@"%@ %@",[self humanReadableStringFromBytes:[self fileSizeAtPath:self.model.path]],time.length ? time : @""];
            });
        }
    });
}

// 遍历文件夹获得文件夹大小
- (NSString *)folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return [self humanReadableStringFromBytes:folderSize];
}

// 单个文件的大小
- (long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

// 计算文件大小
- (NSString *)humanReadableStringFromBytes:(unsigned long long)byteCount
{
    float numberOfBytes = byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB",@"EB",@"ZB",@"YB",nil];
    
    while (numberOfBytes > 1024) {
        numberOfBytes /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",numberOfBytes, [tokens objectAtIndex:multiplyFactor]];
}

// 时间
- (NSString *)fileTimeAtPath:(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
    
    NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
        
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:fileCreateDate];
}

- (void)setIconImage
{
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:self.model.path isDirectory:&isDirectory];
    
    if (isDirectory) {
        
        self.iconImageV.hidden = NO;
        self.playImageV.hidden = YES;
        self.iconImageLabel.hidden = YES;
        NSString *path = [[[NSBundle mainBundle] pathForResource:@"LPSandBoxFile" ofType:@".bundle"] stringByAppendingPathComponent:@"file.png"];
        
        // 文件夹
        self.iconImageV.image = [UIImage imageWithContentsOfFile:path];
    }else{
        
        NSString *form = [[self.model.path pathExtension] lowercaseString];
        
        if ([form isEqualToString:@"jpg"] || [form isEqualToString:@"png"] || [form isEqualToString:@"heic"]) {
            
            self.iconImageV.hidden = NO;
            self.playImageV.hidden = YES;
            self.iconImageLabel.hidden = YES;
            
            if (self.model.image) {
                
                self.iconImageV.image = self.model.image;
            }else{
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    self.model.image = [self getThumbnailImageWithPath:self.model.path];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        self.iconImageV.image = self.model.image;
                    });
                });
            }
        }else if ([form isEqualToString:@"mp4"] || [form isEqualToString:@"mov"]) {
            
            self.iconImageV.hidden = NO;
            self.playImageV.hidden = NO;
            self.iconImageLabel.hidden = YES;
            
            if (self.model.image) {
                
                self.iconImageV.image = self.model.image;
            }else{
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    self.model.image = [self getImageForVideoWithURLStr:self.model.path];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        self.iconImageV.image = self.model.image;
                    });
                });
            }
        }else{
            
            self.iconImageV.hidden = YES;
            self.playImageV.hidden = YES;
            self.iconImageLabel.hidden = NO;
            self.iconImageLabel.text = [self.model.path pathExtension];
        }
    }
}

// 图片缩略图
- (UIImage *)getThumbnailImageWithPath:(NSString *)path
{
    // 图片宽高
    int imageSize = IconImageWH*2;
    CGImageRef thumbImage;
    CGImageSourceRef imageSource;
    CFDictionaryRef imageOption;
    
    CFStringRef imageKeys[3];
    CFTypeRef imageValues[3];
    
    //缩略图尺寸
    CFNumberRef thumbSize;
    
    imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], NULL);
    if (imageSource == nil) {
        return nil;
    }
    
    //创建缩略图等比缩放大小，会根据长宽值比较大的作为imageSize进行缩放
    thumbSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    
    imageKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    imageValues[0] = (CFTypeRef)kCFBooleanTrue;
    
    imageKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    imageValues[1] = (CFTypeRef)kCFBooleanTrue;
  
    //缩放键值对
    imageKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    imageValues[2] = (CFTypeRef)thumbSize;
    
    
    imageOption = CFDictionaryCreate(NULL, (const void **) imageKeys,
                                      (const void **) imageValues, 3,
                                      &kCFTypeDictionaryKeyCallBacks,
                                      &kCFTypeDictionaryValueCallBacks);
    
    //获取缩略图
    thumbImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, imageOption);
    
    CFRelease(imageOption);
    CFRelease(imageSource);
    CFRelease(thumbSize);
        
    //显示缩略图
    return [UIImage imageWithCGImage:thumbImage];
}

// 根据url获取视频第一帧图片
- (UIImage *)getImageForVideoWithURLStr:(NSString *)urlStr
{
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        
    if (!urlStr.length) return nil;
        
    UIImage *shotImage;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:urlStr] options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    shotImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
        
    NSLog(@"time = %f",CFAbsoluteTimeGetCurrent()-start);
    
    return shotImage;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self iconImageV];
    
    [self iconImageLabel];
    
    [self playImageV];
    
    [self titlelabel];
    
    [self detailsLabel];
}

- (UIImageView *)iconImageV
{
    if (!_iconImageV) {
                        
        _iconImageV = [[UIImageView alloc] initWithFrame:CGRectMake(gap, gap/2, IconImageWH, IconImageWH)];
        _iconImageV.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageV.layer.masksToBounds = YES;
//        _iconImageV.backgroundColor = UIColor.orangeColor;
        [self.contentView addSubview:_iconImageV];
    }
    
    return _iconImageV;
}

- (UIImageView *)playImageV
{
    if (!_playImageV) {
                        
        _playImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IconImageWH/2, IconImageWH/2)];
        _playImageV.center = _iconImageV.center;
        _playImageV.layer.masksToBounds = YES;
        _playImageV.hidden = YES;
        NSString *path = [[[NSBundle mainBundle] pathForResource:@"LPSandBoxFile" ofType:@".bundle"] stringByAppendingPathComponent:@"play.png"];
        _playImageV.image = [UIImage imageWithContentsOfFile:path];;
//        _iconImageV.backgroundColor = UIColor.orangeColor;
        [self.contentView addSubview:_playImageV];
    }
    
    return _playImageV;
}


- (UILabel *)iconImageLabel
{
    if (!_iconImageLabel) {
        _iconImageLabel = [[UILabel alloc] initWithFrame:_iconImageV.frame];
        _iconImageLabel.backgroundColor = ColorWihthRGB(81, 159, 81);
        _iconImageLabel.layer.cornerRadius = 5.0;
        _iconImageLabel.layer.masksToBounds = YES;
        _iconImageLabel.hidden = YES;
        _iconImageLabel.textAlignment = NSTextAlignmentCenter;
        _iconImageLabel.textColor = [UIColor whiteColor];
        _iconImageLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_iconImageLabel];
    }
    
    return _iconImageLabel;
}

- (UILabel *)titlelabel
{
    if (!_titlelabel) {
        
        CGFloat x = gap + IconImageWH + gap;
        
        _titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(x, LPFileListVCCellH * 0.1, ScreenW - x - gap, 30)];
        _titlelabel.font = [UIFont systemFontOfSize:16];
        _titlelabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_titlelabel];
    }
    
    return _titlelabel;
}

- (UILabel *)detailsLabel
{
    if (!_detailsLabel) {
        
        CGFloat x = gap + IconImageWH + gap;

        _detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, LPFileListVCCellH * 0.5, ScreenW - x - gap, 20)];
        _detailsLabel.font = [UIFont systemFontOfSize:14];
        _detailsLabel.textColor = ColorWihthRGB(100, 100, 100);
        [self.contentView addSubview:_detailsLabel];
    }
    
    return _detailsLabel;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *reuseId = @"LPFileListVCCell";
    
    LPFileListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
        cell = [[LPFileListVCCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}

@end
