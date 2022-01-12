//
//  BeautyProgressView.h
//  INTERACTIVE-LIVE-iOS
//
//  Created by admin on 2021/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeautyProgressView : UIView
@property(nonatomic,strong)NSString *Color_TGress;
- (instancetype)initWithFrame:(CGRect)frame;
-(void)updateProgressWithValue:(CGFloat)progress;
-(void)resetProgress;
@end

NS_ASSUME_NONNULL_END
