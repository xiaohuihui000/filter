//
//  SGMeiyanFilter.m
//  GPUImage
//
//  Created by 小平 张 on 16/7/6.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import "SGMeiyanFilter.h"

@implementation SGMeiyanFilter

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    // First pass: face smoothing filter
    bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    bilateralFilter.distanceNormalizationFactor = 4.0;
    [self addFilter:bilateralFilter];
    
    // Second pass: edge detection
    cannyEdgeFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
    [self addFilter:cannyEdgeFilter];
    
    // Third pass: combination bilateral, edge detection and origin
    combinationFilter = [[SGCombineFilter alloc] init];
    [self addFilter:combinationFilter];
    
    [bilateralFilter addTarget:combinationFilter];
    [cannyEdgeFilter addTarget:combinationFilter];
    
    // Adjust HSB
    hsbFilter = [[GPUImageHSBFilter alloc] init];
    [hsbFilter adjustBrightness:1.1]; // 加亮
    [hsbFilter adjustSaturation:1.1]; // 饱和度
    [combinationFilter addTarget:hsbFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:bilateralFilter,cannyEdgeFilter,combinationFilter,nil];
    self.terminalFilter = hsbFilter;
    
    return self;
}

#pragma mark -
#pragma mark GPUImageInput protocol

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    for (GPUImageOutput<GPUImageInput> *currentFilter in self.initialFilters)
    {
        if (currentFilter != self.inputFilterToIgnoreForUpdates)
        {
            if (currentFilter == combinationFilter) {
                textureIndex = 2;
            }
            [currentFilter newFrameReadyAtTime:frameTime atIndex:textureIndex];
        }
    }
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    for (GPUImageOutput<GPUImageInput> *currentFilter in self.initialFilters)
    {
        if (currentFilter == combinationFilter) {
            textureIndex = 2;
        }
        [currentFilter setInputFramebuffer:newInputFramebuffer atIndex:textureIndex];
    }
}

@end

