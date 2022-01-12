//
//  BeautyCameraView.m
//  INTERACTIVE-LIVE-iOS
//
//  Created by admin on 2021/6/24.
//
#import "BeautyCameraView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"
#import "BeautyProgressView.h"
#import "BeautyCameraModel.h"
#import "GatherSDK.h"


@interface BeautyCameraView()
@property (nonatomic, weak) GPUImageBrightnessFilter *bilateralFilter;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, weak) GPUImageView *captureVideoPreview;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageMovie *movieW;
@property (nonatomic, strong) NSURL *movieURL;//视频路径
@property (nonatomic, strong) UIButton *backBtn;//返回按钮
@property (nonatomic, strong) UIButton *beautyBtn;//美颜按钮
@property (nonatomic, strong) UIButton *cameraBtn;//切换摄像头按钮
@property (nonatomic, strong) UIButton *recordBtn;//录制按钮
@property (nonatomic, strong) UIButton *clearBtn;//清除按钮
@property (nonatomic, strong) UIButton *selectBtn;//选择按钮
@property (strong,nonatomic)  UIImageView *focusCursor; //聚焦光标
@property (nonatomic, strong) BeautyProgressView *progressView;//进度按钮
@property (nonatomic, strong) UIView *timeView;//时间背景view
@property (nonatomic, strong) UILabel *timelabel;//时间Label
@property (nonatomic, strong) NSTimer *timer;//定时器
@property (nonatomic, assign) CGFloat recordTime;

@end

@implementation BeautyCameraView
#pragma mark - lazy

- (UIImageView *)focusCursor
{
    if (!_focusCursor) {
        _focusCursor = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
        _focusCursor.image = [UIImage imageNamed:@"focusImg"];
        _focusCursor.hidden = YES;
    }
    return _focusCursor;
}

#pragma mark - instancetype

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configUI:false];
        [self configCamera];
    }return  self;
}
- (instancetype)initWithFrame:(CGRect)frame IsTest:(BOOL)isTest{
    if (self = [super initWithFrame:frame]) {
        [self configUI:isTest];
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
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
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
    //给预览视图添加聚焦功能
    [self addSubview:self.focusCursor];
    UITapGestureRecognizer *tapGesture= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [_captureVideoPreview addGestureRecognizer:tapGesture];
    // 设置处理链
    [_videoCamera addTarget:_captureVideoPreview];
    [self setmoveWriter];
    //
    self.beautyBtn.tag = YES;
    [self done:self.beautyBtn];
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
}

#pragma mark - action
- (void)done:(UIButton*)Btn{
    if (Btn == self.beautyBtn) {//添加滤镜
        if (Btn.tag) {
            Btn.tag = NO;
            [self.beautyBtn setImage:[UIImage imageNamed:@"icon_live_beauty"] forState:UIControlStateNormal];
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
            //[_videoCamera addTarget:_captureVideoPreview];
        }else{
            Btn.tag = YES;
            [self.beautyBtn setImage:[UIImage imageNamed:@"icon_live_beauty_40"] forState:UIControlStateNormal];
            // 移除之前所有处理链
            [_videoCamera removeAllTargets];
            
            // 创建美颜滤镜
            GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
            
            // 设置GPUImage处理链，从数据源 => 滤镜 => 最终界面效果
            [_videoCamera addTarget:beautifyFilter];
            //添加滤镜到预览视图
            [beautifyFilter addTarget:_captureVideoPreview];
            //添加滤镜到到写入文件
            [beautifyFilter addTarget:_movieWriter];
        }
    }else if(Btn == self.cameraBtn){//切换摄像头
        Btn.tag = Btn.tag ? NO : YES;
        [self.videoCamera rotateCamera];
    }else if(Btn == self.backBtn){//返回
        if (self.delegate && [self.delegate respondsToSelector:@selector(beautyCameraViewDelegateActions:)]) {
            [_delegate beautyCameraViewDelegateActions:0];
        }
    }else if(Btn == self.clearBtn){//重置
        [self resetRecord];
    }else if(Btn == self.selectBtn){//选择
        NSData *data = [NSData dataWithContentsOfURL:self.movieURL];
        if (data.length>1024*1024*100) {
            alert(@"上传视频不能大于100M")
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(beautyCameraViewDelegateoutUrl:)]) {
            [self.delegate beautyCameraViewDelegateoutUrl:self.movieURL];
        }
    }else{//开始or结束录制
        if (Btn.tag) {
            Btn.tag = NO;
            [_movieWriter finishRecordingWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self finshRecord];
                });
            }];
        }else{
            Btn.tag = YES;
            //开始录制
            [self starRecord];
        }
    }
}

//开始录制
- (void)starRecord{
    [_movieWriter startRecording];
    [self.progressView resetProgress];
    [self changeToRecordStyle];
    //[self setmoveWriter];
    if (!self.timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        });
    }
}

//录制完成
- (void)finshRecord{
    [self.timer invalidate];
    [self changeToStopStyle];
    self.timer = nil;
    self.videoCamera.audioEncodingTarget = nil;
    [self.videoCamera stopCameraCapture];
    self.progressView.hidden = YES;
    self.recordBtn.hidden = YES;
    self.clearBtn.hidden = NO;
    self.selectBtn.hidden = NO;
    [self.progressView resetProgress];
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (@available(iOS 9.0, *)) {
            NSError *error;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:weakSelf.movieURL];
                NSLog(@"%@",error);
            } error:&error];
        }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib writeVideoAtPathToSavedPhotosAlbum:weakSelf.movieURL completionBlock:nil];
#pragma clang diagnostic pop
        }
    });
}

//重置录制
- (void)resetRecord{
    [self setmoveWriter];
    [self changeToStopStyle];
    self.recordTime = 0.0;
    self.timelabel.text = @"00:00";
    self.progressView.hidden = NO;
    self.recordBtn.hidden = NO;
    self.clearBtn.hidden = YES;
    self.selectBtn.hidden = YES;
    [self.progressView resetProgress];
}



//更新录制进度
- (void)updateProgress{
    _recordTime += TIMER_INTERVAL;
    CGFloat progress = _recordTime/RECORD_MAX_TIME * 1.0;
    [self.progressView updateProgressWithValue:progress];
    self.timelabel.text = [self changeToVideotime:progress * RECORD_MAX_TIME];
    if (_recordTime == RECORD_MAX_TIME){
        [self done:self.recordBtn];
    }
}

- (NSString *)changeToVideotime:(CGFloat)videocurrent{
    return [NSString stringWithFormat:@"%02li:%02li",lround(floor(videocurrent/60.f)),lround(floor(videocurrent/1.f))%60];
}

//录制按钮动画
- (void)changeToRecordStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordBtn.center;
        CGRect rect = self.recordBtn.frame;
        rect.size = CGSizeMake(28, 28);
        self.recordBtn.frame = rect;
        self.recordBtn.layer.cornerRadius = 4;
        self.recordBtn.center = center;
    }];
}

- (void)changeToStopStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordBtn.center;
        CGRect rect = self.recordBtn.frame;
        rect.size = CGSizeMake(52, 52);
        self.recordBtn.frame = rect;
        self.recordBtn.layer.cornerRadius = 26;
        self.recordBtn.center = center;
    }];
}

-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point =  [tapGesture locationInView:tapGesture.view];
    UIView *preView = tapGesture.view;
    CGPoint focusPoint = CGPointMake(point.x/preView.frame.size.width, point.y/preView.frame.size.height);
    NSError *error;
    if([self.videoCamera.inputCamera lockForConfiguration:&error]){
        //对焦模式和对焦点,设定前一定要判断该模式是否支持，如果支持就先设定位置，然后再设定模式，单独设定位置是没有用的。曝光设置跟这里一样的原理
        if([self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
            [self.videoCamera.inputCamera setFocusPointOfInterest:focusPoint];
            [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        //曝光模式和曝光点
        if([self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
            [self.videoCamera.inputCamera setExposurePointOfInterest:focusPoint];
            [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        //当你lockForConfiguration后，完成设置后记住一定要unlock
        [self.videoCamera.inputCamera unlockForConfiguration];
        //设置对焦动画
        _focusCursor.center = point;
        _focusCursor.hidden = NO;
        [UIView animateWithDuration:0.3f animations:^{
            self.focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f animations:^{
                self.focusCursor.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusCursor.hidden = YES;
            }];
            
        }];
    }
}

- (void)configUI:(BOOL)isTest{
    // Do any additional setup after loading the view.
    self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(12, kSafeArea_Top, 75, 40)];
    [self.backBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backBtn];
    if (isTest){
        //视频测试
        [self.backBtn setImage:[UIImage imageNamed:@"icon_top_closed"] forState:UIControlStateNormal];
        self.backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth-105)/2, kSafeArea_Top, 105, 44)];
        titleLab.text = @"Live Testing";
        titleLab.textColor = UIColor.whiteColor;
        titleLab.font = [UIFont systemFontOfSize:17];
        [self addSubview:titleLab];
        UIView *_contentView = [[UIView alloc]initWithFrame:CGRectMake(12, kScreenHeight-kSafeArea_Bottom-136, 283, 64)];
        UILabel *houlderLab = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 243, 64)];
        houlderLab.text = @"You are testing the live effect. The video\n can only be seen by yourself. If you have\n any question, please let us kown.";
        houlderLab.textColor = [UIColor colorWithHexString:@"0xFFBE00" alpha:1];
        houlderLab.font = [UIFont systemFontOfSize:12];
        houlderLab.numberOfLines = 0;
        UIImageView *leftHoulder = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
        leftHoulder.image = [UIImage imageNamed:@"logo_head_24"];
        [_contentView addSubview:leftHoulder];
        [_contentView addSubview:houlderLab];
        _contentView.layer.cornerRadius = 20;
        
        UITextField *_inputView = [[UITextField alloc]initWithFrame:CGRectMake(12, kScreenHeight-kSafeArea_Bottom-56, 283, 40)];
        UIView *leftinputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 45, 35)];
        UIImageView *leftinputHoulder = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 25, 25)];
        [leftinputView addSubview:leftinputHoulder];
        leftinputHoulder.image = [UIImage imageNamed:@"icon_you_message_24"];
        _inputView.leftView = leftinputView;
        _inputView.leftViewMode = UITextFieldViewModeAlways;
        _inputView.enabled = NO;
        _inputView.placeholder = @"write";
        _inputView.text = @"write";
        _inputView.layer.cornerRadius = 20;
        _inputView.textColor = UIColor.whiteColor;
        
        _inputView.backgroundColor = [UIColor colorWithHexString:@"0x333333" alpha:0.25];
        _contentView.backgroundColor = [UIColor colorWithHexString:@"0x333333" alpha:0.25];

        [self addSubview:_inputView];
        [self addSubview:_contentView];
        
        
        return;
    }
    self.cameraBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 52,  kSafeArea_Top, 40, 40)];
    [self.cameraBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cameraBtn];
    self.beautyBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 52, kSafeArea_Top + 60, 40, 40)];
    [self.beautyBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.beautyBtn];
    [self.backBtn setImage:[UIImage imageNamed:@"icon_top_fanhui"] forState:UIControlStateNormal];
    [self.beautyBtn setImage:[UIImage imageNamed:@"icon_live_beauty"] forState:UIControlStateNormal];
    [self.beautyBtn setImage:[UIImage imageNamed:@"icon_live_beauty_40"] forState:UIControlStateNormal];
    [self.cameraBtn setImage:[UIImage imageNamed:@"icon_zhibo_switchingcamera"] forState:UIControlStateNormal];
    self.backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.timeView = [[UIView alloc] init];
    self.timeView.frame = CGRectMake((kScreenWidth - 80)/2, kSafeArea_Top, 80, 36);
    self.timeView.backgroundColor = [UIColor colorWithRGB:0x242424 alpha:0.7];
    self.timeView.layer.cornerRadius = 18;
    self.timeView.layer.masksToBounds = YES;
    [self addSubview:self.timeView];
    
    self.timelabel =[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 80)/2, kSafeArea_Top, 80, 36)];
    self.timelabel.font = [UIFont systemFontOfSize:16];
    self.timelabel.textColor = [UIColor colorWithHexString:self.Color_CTX];
    self.timelabel.text = @"00:00";
    self.timelabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.timelabel];
    
    
    self.progressView = [[BeautyProgressView alloc] initWithFrame:CGRectMake((kScreenWidth - 74)/2, kScreenHeight - kSafeArea_Bottom - 32 - 74, 74, 74)];
    self.progressView.Color_TGress = _Color_CTPX;
    self.progressView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.progressView];
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    self.recordBtn.frame = CGRectMake(5, 5, 64, 64);
    self.recordBtn.backgroundColor = [UIColor colorWithHexString:self.Color_CTPX];
    self.recordBtn.layer.cornerRadius = 32;
    self.recordBtn.layer.masksToBounds = YES;
    [self.progressView addSubview:self.recordBtn];
    [self.progressView resetProgress];
    
    self.clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //self.clearBtn.frame = CGRectMake(kScreenWidth/2 - 76 - 56, kScreenHeight - 32 - 69, 56, 56);
    self.clearBtn.frame = CGRectMake(kScreenWidth/2 - 38 - 56, kScreenHeight - kSafeArea_Bottom - 32 - 69, 56, 56);
    [self.clearBtn setImage:[UIImage imageNamed:@"icon_release_video_del"] forState:UIControlStateNormal];
    [self.clearBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearBtn sizeToFit];
    self.clearBtn.hidden = YES;
    [self addSubview:self.clearBtn];
    
    self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectBtn.frame = CGRectMake(kScreenWidth/2 + 38, kScreenHeight - kSafeArea_Bottom - 32 - 69, 56, 56);
    [self.selectBtn setImage:[UIImage imageNamed:@"icon_release_video_submit"] forState:UIControlStateNormal];
    [self.selectBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [self.selectBtn sizeToFit];
    self.selectBtn.hidden = YES;
    [self addSubview:self.selectBtn];
}
- (void)setColor_CTX:(NSString *)Color_CTX{
    _Color_CTX = Color_CTX;
    self.timelabel.textColor = [UIColor colorWithHexString:self.Color_CTX];
}
- (void)setColor_CTPX:(NSString *)Color_CTPX{
    _Color_CTPX = Color_CTPX;
    self.progressView.Color_TGress = _Color_CTPX;
    self.recordBtn.backgroundColor = [UIColor colorWithHexString:_Color_CTPX];
}
@end
