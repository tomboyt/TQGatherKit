//
//  BeautyCameraViewController.h
//  INTERACTIVE-LIVE-iOS
//
//  Created by admin on 2021/6/23.
//
//  美颜滤镜
#import "GPUImage.h"
//#import <GPUImage/GPUImage.h>

@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

@end
