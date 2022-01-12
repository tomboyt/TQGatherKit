//
//  BeautyCameraViewController.h
//  INTERACTIVE-LIVE-iOS
//
//  Created by admin on 2021/6/23.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor*)colorWithRGB:(NSUInteger)hex alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor*)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
//高斯图
+ (UIImage *)setImageEffecteWith:(UIImage *)image radius:(CGFloat)radius;
@end
