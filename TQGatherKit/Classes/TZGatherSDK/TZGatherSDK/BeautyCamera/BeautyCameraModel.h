//
//  BeautyCameraModel.h
//  INTERACTIVE-LIVE-iOS
//
//  Created by admin on 2021/6/23.
//

#define VIDEO_FOLDER @"videoFolder" //视频录制存放文件夹

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeautyCameraModel : NSObject

/// 存放视频的文件夹
+ (NSString *)videoFolder;
/// 写入的视频路径
+ (NSString *)createVideoFilePath;
@end

NS_ASSUME_NONNULL_END
