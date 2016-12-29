//
//  GPUFour.m
//  GPUImage
//
//  Created by chenguanghui on 16/12/27.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import "GPUFour.h"
NSString *const kGPUImageFourVertexShaderString = SHADER_STRING
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

NSString *const kGPUImageFourFragmentShaderString = SHADER_STRING
(
 
 
 
 varying lowp vec2 textureCoordinate;
 
 varying lowp vec2 varyOtherPostion;
 
 uniform sampler2D inputImageTexture;
 
 void main(){
     
     if (varyOtherPostion.x<=0.0) {
         if (varyOtherPostion.y<=0.0) {
             lowp vec2 test = vec2((varyOtherPostion.x+1.0),(varyOtherPostion.y+1.0));
             gl_FragColor = texture2D(inputImageTexture,test);
         }
         else if(varyOtherPostion.x<=1.0){
             lowp vec2 test = vec2(varyOtherPostion.x+1.0,varyOtherPostion.y);
             gl_FragColor = texture2D(inputImageTexture,test);
         }
     }
     else if(varyOtherPostion.x<=1.0){
         if (varyOtherPostion.y<=0.0) {
             lowp vec2 test = vec2(varyOtherPostion.x,varyOtherPostion.y+1.0);
             gl_FragColor = texture2D(inputImageTexture,test);
         }
         else if(varyOtherPostion.y<=1.0){
             lowp vec2 test = vec2(varyOtherPostion.x,varyOtherPostion.y);
             gl_FragColor = texture2D(inputImageTexture,test);
         }
     }

 }
 );


@implementation GPUFour
- (instancetype)init{
    if (self = [super initWithVertexShaderFromString:kGPUImageFourVertexShaderString fragmentShaderFromString:kGPUImageFourFragmentShaderString]) {
        
    }
    return self;
}
@end
