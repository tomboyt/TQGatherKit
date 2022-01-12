//
//  figureCameraView.h
//  TZGatherSDK
//
//  Created by admin on 2021/11/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol figureCameraViewDelegate <NSObject>

- (void)figureCameraViewDelegateupdateTimes:(int)costTime;
- (void)figureCameraViewDelegateoutUrl:(NSURL*)videoUrl;

@end

@interface figureCameraView : UIView

- (void)preRecord;
- (void)starRecord;
- (void)finshRecord;
- (void)resetRecord;
@property (nonatomic,weak)id <figureCameraViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
