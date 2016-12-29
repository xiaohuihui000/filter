//
//  GPUMirror.m
//  filter_demo
//
//  Created by chenguanghui on 16/12/27.
//  Copyright © 2016年 chenguanghui. All rights reserved.
//

#import "GPUMirror.h"


NSString *const kGPUImageMirrorVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 textCoordinate;

 varying lowp vec2 textureCoordinate;
 varying lowp vec2 varyOtherPostion;
 void main()
 {
     textureCoordinate = textCoordinate;
     varyOtherPostion = position.xy;
    gl_Position = position;
     
 }
 );

NSString *const kGPUImageMirrorFragmentShaderString = SHADER_STRING
(

 
 
 varying lowp vec2 textureCoordinate;
 
 varying lowp vec2 varyOtherPostion;
 
 uniform sampler2D inputImageTexture;
        
    void main(){
        
        if (varyOtherPostion.x < 0.0) {

            lowp vec4 backColor = texture2D(inputImageTexture, textureCoordinate);
            gl_FragColor = backColor;
        }
        else {
            lowp vec2 test = vec2((1.0-varyOtherPostion.x)/2.0,(1.0+varyOtherPostion.y)/2.0);
            gl_FragColor = texture2D(inputImageTexture, test);
        }
    }
);


@implementation GPUMirror

- (instancetype)init{
    if (self = [super initWithVertexShaderFromString:kGPUImageMirrorVertexShaderString fragmentShaderFromString:kGPUImageMirrorFragmentShaderString]) {
        
    }
    return self;
}

@end
