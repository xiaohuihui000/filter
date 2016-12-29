//
//  SGMeiyanFilter.h
//  GPUImage
//
//  Created by 小平 张 on 16/7/6.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import "GPUImageBilateralFilter.h"
#import "GPUImageCannyEdgeDetectionFilter.h"
#import "SGCombineFilter.h"
#import "GPUImageHSBFilter.h"


@interface SGMeiyanFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter             *bilateralFilter;   //双边模糊
    GPUImageCannyEdgeDetectionFilter    *cannyEdgeFilter;   //边缘检测
    SGCombineFilter                     *combinationFilter; //
    GPUImageHSBFilter                   *hsbFilter;         //
}

@end
