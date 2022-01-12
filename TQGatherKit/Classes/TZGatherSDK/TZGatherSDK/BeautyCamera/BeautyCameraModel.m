//
//  BeautyCameraModel.m
//  INTERACTIVE-LIVE-iOS
//
//  Created by admin on 2021/6/23.
//

#import "BeautyCameraModel.h"
#import "LiveFileManager.h"
@implementation BeautyCameraModel

//存放视频的文件夹
+ (NSString *)videoFolder
{
    NSString *cacheDir = [LiveFileManager cachesDir];
    NSString *direc = [cacheDir stringByAppendingPathComponent:VIDEO_FOLDER];
    if (![LiveFileManager isExistsAtPath:direc]) {
        [LiveFileManager createDirectoryAtPath:direc];
    }
    return direc;
}
//写入的视频路径
+ (NSString *)createVideoFilePath
{
    //NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    ////判断路径是否存在
    //unlink([pathToMovie UTF8String]);
    //self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
    NSString *path = [[self videoFolder] stringByAppendingPathComponent:videoName];
    return path;
    
}
@end

