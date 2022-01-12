//
//  BeautyCameraView.h
//  INTERACTIVE-LIVE-iOS
//
//  Created by admin on 2021/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BeautyCameraViewDelegate <NSObject>

- (void)beautyCameraViewDelegateActions:(NSInteger)action;
- (void)beautyCameraViewDelegateoutUrl:(NSURL*)videoUrl;

@end

@interface BeautyCameraView : UIView
@property (nonatomic,strong)NSString *Color_CTX;
@property (nonatomic,strong)NSString *Color_CTPX;
                                                                                                    
@property (nonatomic,weak)id <BeautyCameraViewDelegate>delegate;
- (instancetype)initWithFrame:(CGRect)frame IsTest:(BOOL)isTest;
@end

NS_ASSUME_NONNULL_END
