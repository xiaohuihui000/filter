//
//  SGCombineFilter.m
//  GPUImage
//
//  Created by 小平 张 on 16/7/6.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import "SGCombineFilter.h"

// 正常结果
NSString *const kGPUImageBeautifyFragmentShaderString = SHADER_STRING
(
    varying highp vec2 textureCoordinate;
    varying highp vec2 textureCoordinate2;
    varying highp vec2 textureCoordinate3;

    uniform sampler2D inputImageTexture;
    uniform sampler2D inputImageTexture2;
    uniform sampler2D inputImageTexture3;
    uniform mediump float smoothDegree;

    void main()
    {
     highp vec4 bilateral = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 canny = texture2D(inputImageTexture2, textureCoordinate2);
     highp vec4 origin = texture2D(inputImageTexture3,textureCoordinate3);
     highp vec4 smooth;
     lowp float r = origin.r;
     lowp float g = origin.g;
     lowp float b = origin.b;
     
     if( canny.r >= 0.2 ){
         smooth = origin;
     }else if(r > 0.3725 && g > 0.1568 && b > 0.0784 && r > b && (max(max(r, g), b) - min(min(r, g), b)) > 0.0588 && abs(r-g) > 0.0588){
         smooth = origin * (1.0-smoothDegree) + bilateral * smoothDegree;
     }else{
         smooth = origin * 0.8 + bilateral * 0.2;
     }
     
     smooth.r = log(1.0 + 0.2 * smooth.r)/log(1.2);
     smooth.g = log(1.0 + 0.2 * smooth.g)/log(1.2);
     smooth.b = log(1.0 + 0.2 * smooth.b)/log(1.2);
     gl_FragColor = smooth;
    }
);


// 展示各个单向输入
NSString *const kGPUImageBeautifyFragmentShaderString_SINGLE = SHADER_STRING
(
    varying highp vec2 textureCoordinate;
    varying highp vec2 textureCoordinate2;
    varying highp vec2 textureCoordinate3;

    uniform sampler2D inputImageTexture;
    uniform sampler2D inputImageTexture2;
    uniform sampler2D inputImageTexture3;
    uniform mediump float smoothDegree;

    void main()
    {
     highp vec4 bilateral = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 canny = texture2D(inputImageTexture2, textureCoordinate2);
     highp vec4 origin = texture2D(inputImageTexture3,textureCoordinate3);
     highp vec4 smooth;
     lowp float r = bilateral.r;
     lowp float g = bilateral.g;
     lowp float b = bilateral.b;
     gl_FragColor = canny;
    }
);


// 这个是展示皮肤检测的结果
NSString *const kGPUImageBeautifyFragmentShaderString_SKIN = SHADER_STRING
(
    varying highp vec2 textureCoordinate;
    varying highp vec2 textureCoordinate2;
    varying highp vec2 textureCoordinate3;

    uniform sampler2D inputImageTexture;
    uniform sampler2D inputImageTexture2;
    uniform sampler2D inputImageTexture3;
    uniform mediump float smoothDegree;

    void main()
    {
     highp vec4 bilateral = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 canny = texture2D(inputImageTexture2, textureCoordinate2);
     highp vec4 origin = texture2D(inputImageTexture3,textureCoordinate3);
     highp vec4 smooth;
     lowp float r = origin.r;
     lowp float g = origin.g;
     lowp float b = origin.b;
     if (canny.r < 0.2 && r > 0.3725 && g > 0.1568 && b > 0.0784 && r > b && (max(max(r, g), b) - min(min(r, g), b)) > 0.0588 && abs(r-g) > 0.0588) {
         smooth = vec4(1.0,0.0,0.0,1.0);
     }
     else {
         smooth = vec4(0.0,1.0,0.0,1.0);
     }
     gl_FragColor = smooth;
    }
);


@implementation SGCombineFilter

- (id)init {
    if (self = [super initWithFragmentShaderFromString:kGPUImageBeautifyFragmentShaderString]) {
        smoothDegreeUniform = [filterProgram uniformIndex:@"smoothDegree"];
    }
    self.intensity = 0.7; // 原图 到 双边过滤 的混合比例
    return self;
}

- (void)setIntensity:(CGFloat)intensity {
    _intensity = intensity;
    [self setFloat:intensity forUniform:smoothDegreeUniform program:filterProgram];
}

@end
