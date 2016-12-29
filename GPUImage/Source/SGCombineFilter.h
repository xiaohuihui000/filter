//
//  SGCombineFilter.h
//  GPUImage
//
//  Created by 小平 张 on 16/7/6.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import "GPUImageThreeInputFilter.h"

// Internal CombinationFilter(It should not be used outside)
@interface SGCombineFilter : GPUImageThreeInputFilter
{
    GLint smoothDegreeUniform;
}

@property (nonatomic, assign) CGFloat intensity;

@end
