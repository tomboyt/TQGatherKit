//
//  figureCameraView.m
//  TZGatherSDK
//
//  Created by admin on 2021/11/2.
//

#import "figureCameraView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"
#import "BeautyProgressView.h"
#import "BeautyCameraModel.h"
#import "GatherSDK.h"

@interface figureCameraView ()

@property (nonatomic, weak) GPUImageBrightnessFilter *bilateralFilter;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, weak) GPUImageView *captureVideoPreview;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageMovie *movieW;
@property (nonatomic, strong) NSURL *movieURL;//视频路径
@property (nonatomic, strong) NSTimer *timer;//定时器
@property (nonatomic, assign) CGFloat recordTime;
@end

@implementation figureCameraView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configCamera];
    }return  self;
    
}

- (void)configCamera{
    //鉴权
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){
        //无权限
        alert(@"无权限")
        return;
    }
    //初始化videocamera 录视频输入源
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset352x288 cameraPosition:AVCaptureDevicePositionFront];
    //设置照片的方向为设备的定向
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    videoCamera.horizontallyMirrorFrontFacingCamera = true;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    //该句可防止允许声音通过的情况下，避免录制第一帧黑屏闪屏
    [videoCamera addAudioInputsAndOutputs];
    _videoCamera = videoCamera;
    //预览View
    GPUImageView *captureVideoPreview = [[GPUImageView alloc] initWithFrame:self.bounds];
    [self insertSubview:captureVideoPreview atIndex:0];
    //显示模式充满整个边框
    captureVideoPreview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    _captureVideoPreview = captureVideoPreview;
    // 设置处理链
    [_videoCamera addTarget:_captureVideoPreview];
    [self setmoveWriter];
    
}

- (void)setmoveWriter{
    
    self.movieURL = [[NSURL alloc] initFileURLWithPath:[BeautyCameraModel createVideoFilePath]];
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_movieURL size:self.bounds.size];
    
    // 开始采集视频,必须调用startCameraCapture，底层才会把采集到的视频源，渲染到GPUImageView中，就能显示了。
    [self.videoCamera startCameraCapture];
    
    //添加音频输入
    _movieWriter.videoInputReadyCallback = ^BOOL{
        return  YES;
    };
    self.videoCamera.audioEncodingTarget = _movieWriter;
    self.movieWriter.shouldPassthroughAudio = YES;
    /*****/
    // 移除之前所有处理链
    [_videoCamera removeAllTargets];
    //创建美白滤镜
    GPUImageBrightnessFilter *bilateralFilter = [[GPUImageBrightnessFilter alloc]init];
    //美白为0
    bilateralFilter.brightness = 0;
    //设置GPUImage处理链，从数据源 => 滤镜 => 最终界面效果
    [_videoCamera addTarget:bilateralFilter];
    //添加到滤镜预览效果
    [bilateralFilter addTarget:_captureVideoPreview];
    //添加滤镜到写入文件
    [bilateralFilter addTarget:_movieWriter];
}

//录制完成
- (void)finshRecord{
    [self.timer invalidate];
    self.timer = nil;
    _recordTime = 0;
    self.videoCamera.audioEncodingTarget = nil;
    [self.videoCamera stopCameraCapture];
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (@available(iOS 9.0, *)) {
            NSError *error;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:weakSelf.movieURL];
                NSLog(@"1234567=%@",error);
                if (self.delegate && [self.delegate respondsToSelector:@selector(figureCameraViewDelegateoutUrl:)]) {
                    [self.delegate figureCameraViewDelegateoutUrl:self.movieURL];
                }
            } error:&error];
        }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib writeVideoAtPathToSavedPhotosAlbum:weakSelf.movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
                NSLog(@"7654321=%@",error);
                if (self.delegate && [self.delegate respondsToSelector:@selector(figureCameraViewDelegateoutUrl:)]) {
                    [self.delegate figureCameraViewDelegateoutUrl:self.movieURL];
                }
            }];
#pragma clang diagnostic pop
            
        }
    });
}
//准备录制
- (void)preRecord{
    if (!self.timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        });
    }
}
//开始录制
- (void)starRecord{
    [self.timer invalidate];
    self.timer = nil;
    [_movieWriter startRecording];
}
//重置录制
- (void)resetRecord{
    [self setmoveWriter];
    self.recordTime = 0.0;
    [self.timer invalidate];
    self.timer = nil;
    [_movieWriter startRecording];
    [self preRecord];
}

//更新录制进度
- (void)updateProgress{
    _recordTime += TIMER_INTERVAL;
    CGFloat progress = _recordTime/5 * 1.0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(figureCameraViewDelegateupdateTimes:)]) {
        [self.delegate figureCameraViewDelegateupdateTimes:progress * 5];
    }
}

- (NSString *)changeToVideotime:(CGFloat)videocurrent{
    return [NSString stringWithFormat:@"%02li",lround(floor(videocurrent/60.f))];
}
@end
