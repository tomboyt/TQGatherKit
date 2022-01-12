//
//  GatherSDK.h
//  TZGatherSDK
//
//  Created by admin on 2021/9/1.
//

#ifndef GatherSDK_h
#define GatherSDK_h
/*1**Device***/
// 判断是否是iPhone X系列
#define IS_iPhoneX      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?\
(\
CGSizeEqualToSize(CGSizeMake(375, 812),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(812, 375),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(414, 896),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(896, 414),[UIScreen mainScreen].bounds.size))\
:\
NO)

#define NAVBAR_HEIGHT       (IS_iPhoneX ? 88.0f : 64.0f)
#define TABBAR_HEIGHT       (IS_iPhoneX ? 83.0f : 49.0f)
#define kSafeArea_Top       (IS_iPhoneX ? 44.0f : 20.0f)
#define kSafeArea_Bottom    (IS_iPhoneX ? 34.0f : 0.0f)

#define kScreenWidth UIScreen.mainScreen.bounds.size.width
#define kScreenHeight UIScreen.mainScreen.bounds.size.height

#define ADAPTATIONRATIO     kScreenWidth / 750.0f
#define GKColorRGBA(r, g, b, a) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]
#define GKColorRGB(r, g, b)     GKColorRGBA(r, g, b, 1.0)

/*2**video***/
#define RECORD_MAX_TIME 300.0//180.0//8.0           //最长录制时间
#define TIMER_INTERVAL 0.05         //计时器刷新频率
#define VIDEO_FOLDER @"videoFolder" //视频录制存放文件夹

/*3**弹框***/
#define alert(str) [[[UIAlertView alloc]initWithTitle:@"" message:str delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

/*4**somefileheader***/
#import "LiveFileManager.h"
#import "UIColor+Hex.h"
#import "BeautyCameraView.h"
#import "figureCameraView.h"

#endif /* GatherSDK_h */
