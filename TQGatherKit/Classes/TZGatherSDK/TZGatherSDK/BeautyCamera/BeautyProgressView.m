//
//  BeautyProgressView.m
//  INTERACTIVE-LIVE-iOS
//
//  Created by admin on 2021/6/26.
//

#import "BeautyProgressView.h"
#import "UIColor+Hex.h"

@interface BeautyProgressView ()

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic,strong ) CAShapeLayer *backLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation BeautyProgressView
@synthesize Color_TGress = _Color_TGress;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}
-(void)updateProgressWithValue:(CGFloat)progress
{
    _progress = progress;
    _progressLayer.opacity = 0;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    
    [self drawCycleProgress];
    
}
- (void)drawCycleProgress
{
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    CGFloat radius = self.frame.size.width/2;
    CGFloat startA = - M_PI_2;
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;

    if (!_backLayer && self.frame.size.width > 0 && self.frame.size.height > 0) {
        _backLayer = [CAShapeLayer layer];
        _backLayer.frame = self.bounds;
        _backLayer.fillColor = [[UIColor clearColor] CGColor];
        _backLayer.strokeColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.25] CGColor];
        _backLayer.opacity = 1; //背景颜色的透明度
        _backLayer.lineCap = kCALineCapRound;
        _backLayer.lineWidth = 10;
        UIBezierPath *path0 = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle: M_PI * 2 clockwise:YES];
        _backLayer.path =[path0 CGPath];
        [self.layer addSublayer:_backLayer];
    }
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor = [[UIColor clearColor] CGColor];
    _progressLayer.strokeColor = [[UIColor colorWithHexString:self.Color_TGress] CGColor];
    NSLog(@"Color_TGress==:%@",self.Color_TGress);
    _progressLayer.opacity = 1; //背景颜色的透明度
    _progressLayer.lineCap = kCALineCapButt;
    _progressLayer.lineWidth = 10;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    _progressLayer.path =[path CGPath];
    [self.layer addSublayer:_progressLayer];
    
}

-(void)resetProgress
{
    [self updateProgressWithValue:0];
}


@end
