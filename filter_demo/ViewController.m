//
//  ViewController.m
//  filter_demo
//
//  Created by chenguanghui on 16/12/27.
//  Copyright © 2016年 chenguanghui. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
#import "GPUImageFilterGroup.h"
#import "GPUOther.h"
#import "GPUFour.h"
#import "SGMeiyanFilter.h"
#import "SGCombineFilter.h"
@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@end

@implementation ViewController
{
    ///设备协调输入输出中心
    AVCaptureSession *_captureSession;
    ///设备
    AVCaptureDevice *_captureDevice;
    /// 输入源
    AVCaptureDeviceInput *_videoCaptureDeviceInput;
    AVCaptureDeviceInput *_audioCaptureDeviceInput;
    
    ///  视频输出
    AVCaptureVideoDataOutput *_captureVideoDataOutput;
    /// 音频输出
    AVCaptureAudioDataOutput *_captureAudioDataOutput;
    /// 队列
    dispatch_queue_t my_Queue;
    /// 视频 连接
    AVCaptureConnection *_videoConnection;
    /// 音频连接
    AVCaptureConnection *_audioConnection;
    
    UIImageView *bufferImageView ;
    
    GPUImageFilter *filter;
    
    NSInteger index;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    index = 0;
    filter = [[SGMeiyanFilter alloc] init];
    
    bufferImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    

    
    [self.view addSubview:bufferImageView];
    
    
    [self initDevide];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
    
}


- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
    
}

/// 初始化
- (void)initDevide {
    
    
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
    _captureDevice = [self frontCamera];
    
    
    
    
    
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    _audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:nil];
    
    _videoCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:nil];
    
    [_captureSession addInput:_videoCaptureDeviceInput];
    [_captureSession addInput:_audioCaptureDeviceInput];
    
    [_captureDevice lockForConfiguration:nil];
    [_captureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1,15)];
    [_captureDevice setActiveVideoMinFrameDuration:CMTimeMake(1,15)];
    [_captureDevice unlockForConfiguration];
    
    
    
    
    _captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    _captureVideoDataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                                        forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [_captureSession addOutput:_captureVideoDataOutput];
    my_Queue = dispatch_queue_create("myqueue", NULL);
    [_captureVideoDataOutput setSampleBufferDelegate:self queue:my_Queue];
    _captureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    
    
    _captureAudioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [_captureAudioDataOutput setSampleBufferDelegate:self queue:my_Queue];
    [_captureSession addOutput:_captureAudioDataOutput];
    
    /// 视频连接
    _videoConnection = [_captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    /// 音频连接
    _audioConnection = [_captureAudioDataOutput connectionWithMediaType:AVMediaTypeAudio];
    
    
    
    [_captureSession startRunning];
    
    
    
    
}






// 丢帧代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"丢帧了");
}

// 抽样缓存写入时所调用的委托程序
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (captureOutput == _captureVideoDataOutput) {
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
        UIImage *filterImage = [filter imageByFilteringImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            bufferImageView.image = filterImage;
        });
    }
}

- (UIImage *)addFiltertoImage:(UIImage *)image{
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:image];
    [inputGPUImage addTarget:filter];
    [filter useNextFrameForImageCapture];
    [inputGPUImage processImage];
    UIImage *filterImage = [filter imageFromCurrentFramebuffer];
    return filterImage;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    switch (index) {
        case 0:
            filter = [[GPUImageColorMatrixFilter alloc] init];
            ((GPUImageColorMatrixFilter*)filter).colorMatrix = (GPUMatrix4x4){
                {0.9510, -0.1133, 0.1622, 0.0},
                {0.0280, 1.0200, -0.0480, 0.0},
                {-0.1334, 0.1350, 0.9984 ,0.0},
                {0,0,0,1.0},
            };
            ((GPUImageColorMatrixFilter*)filter).intensity = 1;
            index = 1;
            break;
        case 1:
            filter = [[GPUImageColorMatrixFilter alloc] init];
            ((GPUImageColorMatrixFilter*)filter).colorMatrix = (GPUMatrix4x4){
                {1.1, 0, 0, 0.0},
                {0, 1.1, 0, 0.0},
                {0, 0, 1.2, 0.0},
                {0,0,0,1.0},
            };
            ((GPUImageColorMatrixFilter*)filter).intensity = 1;
            index = 2;
            break;
        case 2:
            filter = [[GPUImageColorMatrixFilter alloc] init];
            ((GPUImageColorMatrixFilter*)filter).colorMatrix = (GPUMatrix4x4){
                {0.3588, 0.7044, 0.1368, 0.0},
                {0.2990, 0.5870, 0.1140, 0.0},
                {0.2392, 0.4696, 0.0912 ,0.0},
                {0,0,0,1.0},
            };
            ((GPUImageColorMatrixFilter*)filter).intensity = 1;
            index = 3;
            break;
        case 3:
            filter = [[GPUImageColorMatrixFilter alloc] init];
            ((GPUImageColorMatrixFilter*)filter).colorMatrix = (GPUMatrix4x4){
                {0.7880, -0.2617, 0.4736, 0.0},
                {0.1000, 1.0318, -0.1318, 0.0},
                {-0.365, 0.4533, 0.9117 ,0.0},
                {0,0,0,1.0},
            };
            ((GPUImageColorMatrixFilter*)filter).intensity = 1;
            index = 4;
            break;
        case 4:
            filter = [[GPUImageColorMatrixFilter alloc] init];
            ((GPUImageColorMatrixFilter*)filter).colorMatrix = (GPUMatrix4x4){
                {1.0250, 0.1350, -0.1600, 0.0},
                {0.0215, 0.9714, 0.0502, 0.0},
                {0.1399, -0.1132, 0.9733 ,0.0},
                {0,0,0,1.0},
            };
            ((GPUImageColorMatrixFilter*)filter).intensity = 1;
            index = 5;
            break;
        case 5:
            filter = [[GPUMirror alloc] init];
            index = 6;
            break;
        case 6:
            filter = [[GPUOther alloc] init];
            index = 7;
            break;
        case 7:
            filter = [[GPUFour alloc] init];
            index = 0;
            break;
        default:
            break;
    }
}



// 通过抽样缓存数据创建一个UIImage对象
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    if (width == 0 || height == 0) {
        return nil;
    }
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGContextConcatCTM(context, transform);
    
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    struct CGImage *cgImage = CGImageCreateWithImageInRect(quartzImage, CGRectMake(0, 0, width, height));
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    //    UIImage *image =  [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    
    // 释放Quartz image对象
    CGImageRelease(cgImage);
    CGImageRelease(quartzImage);
    return (image);
}

























@end
