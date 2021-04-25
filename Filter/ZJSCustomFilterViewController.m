//
//  ZJSCustomViewController.m
//  Filter
//
//  Created by 周建顺 on 2021/4/23.
//  Copyright © 2021 Hsusue. All rights reserved.
//

#import "ZJSCustomFilterViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <Photos/Photos.h>

#import "EPPSizeFit.h"

#import "EPPCameraTopView.h"
#import "EPPCameraBottomView.h"
#import "ZJSMTKImageFilterSelectView.h"

#import <MetalKit/MTKView.h>
#import "ZJSMTKDelegateView.h"


//https://www.jianshu.com/p/8c7ca1dd7f02/

@interface ZJSCustomFilterViewController ()<AVCapturePhotoCaptureDelegate, EPPCameraTopViewDelegate,EPPCameraBottomViewDelegate,ZJSMTKImageFilterSelectViewDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) EPPCameraTopView *topView;
@property (nonatomic, strong) EPPCameraBottomView *bottomView;
@property (nonatomic, strong) ZJSMTKImageFilterSelectView *filterView;
@property (nonatomic, strong) UIView *previewView;

// 聚焦显示框
@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, strong) UIView *blackView;

@property (nonatomic, strong) AVCaptureDevice *cameraDevice;
@property (nonatomic) AVCaptureSession *captureSession;
// 摄像头输入
@property(nonatomic, strong) AVCaptureDeviceInput *cameraDeviceInput;
@property (nonatomic) AVCapturePhotoOutput *stillImageOutput;
@property (nonatomic, strong) dispatch_queue_t dataOutputQueue;
// Communicate with the session and other session objects on this queue.
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

// 视频输出流
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) CALayer *videoPreviewLayer;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;

// 滤镜用到的
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) CIFilter *filter;

@property (nonatomic, strong) ZJSMTKDelegateView *mtkDelegateView;
@property (nonatomic, strong) id <MTLDevice> metalDevice;
@property (nonatomic, strong) id <MTLCommandQueue> metalCommandQueue;
@property (nonatomic, strong) CIImage *currentCIImage;

@end

@implementation ZJSCustomFilterViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
    [self setupCamera];
    [self setupMTKView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.captureSession isRunning]) {
        [self.captureSession startRunning];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.captureSession stopRunning];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mtkDelegateView.frame = self.previewView.bounds;
    });
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setup{
//    self.ciContext = [CIContext contextWithOptions:nil];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.previewView];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.blackView];
    [self.blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    

    [self.view addSubview:self.filterView];
    [self.view addSubview:self.bottomView];
    
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
    
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
    }];
    

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.focusView];
}

-(void)setupCamera{
    self.flashMode = AVCaptureFlashModeAuto;
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.cameraDevice = backCamera;
//    backCamera.subjectAreaChangeMonitoringEnabled = YES;

    if (!backCamera) {
        NSLog(@"Unable to access back camera!");
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    self.cameraDeviceInput = input;
    if (!error) {
        //Step 9
        self.stillImageOutput = [AVCapturePhotoOutput new];
        self.dataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        self.sessionQueue = dispatch_queue_create("SessionQueue", DISPATCH_QUEUE_SERIAL);
        
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        [_videoDataOutput setSampleBufferDelegate:self queue:self.dataOutputQueue];
        
        if ([self.captureSession canAddInput:input] && [self.captureSession canAddOutput:self.stillImageOutput]&& [self.captureSession canAddOutput:_videoDataOutput]) {
            
            [self.captureSession addInput:input];
            [self.captureSession addOutput:self.stillImageOutput];
            [self.captureSession addOutput:_videoDataOutput];
            [self setupLivePreview];
        }
    }
    else {
        NSLog(@"Error Unable to initialize back camera: %@", error.localizedDescription);
    }
}

- (void)setupLivePreview {
    
//    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.videoPreviewLayer = [[CALayer alloc] init];
    if (self.videoPreviewLayer) {
        
//        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
//        [self.previewView.layer addSublayer:self.videoPreviewLayer];

//        self.previewLayer.anchorPoint = CGPointZero;
    //    _previewLayer.frame = CGRectMake(0, kTopMargin + 50, KScreenWidth, KScreenHeight - 100 - kBottomMargin - 50);
//        [self.previewView.layer addSublayer:self.videoPreviewLayer];
        
        //Step12
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            [self.captureSession startRunning];
            //Step 13
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoPreviewLayer.frame = self.previewView.bounds;
            });
            [self cameraSetting];

        });
    }
}

-(void)setupMTKView{
    self.metalDevice = MTLCreateSystemDefaultDevice();
    self.mtkDelegateView = [[ZJSMTKDelegateView alloc] init];
    self.metalCommandQueue = [self.metalDevice newCommandQueue];
    [self.previewView addSubview:self.mtkDelegateView];
    
    self.ciContext = [CIContext contextWithMTLDevice:self.metalDevice];
    
    self.mtkDelegateView.metalDevice = self.metalDevice;
    self.mtkDelegateView.metalCommandQueue = self.metalCommandQueue;
    self.mtkDelegateView.ciContext = self.ciContext;
//    [self.mtkDelegateView.mtkView setDrawableSize:CGSizeMake(100, 100)];
    
    self.filterView.metalDevice = self.metalDevice;
    self.filterView.metalCommandQueue = self.metalCommandQueue;
    self.filterView.ciContext = self.ciContext;
}


-(void)cameraSetting{
    if ([self.cameraDevice lockForConfiguration:nil]) {
        //自动白平衡
        if ([self.cameraDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.cameraDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        self.cameraDevice.subjectAreaChangeMonitoringEnabled = YES;
        
//        if ([self.cameraDevice isTorchModeSupported:AVCaptureTorchModeOn]) {
//            [self.cameraDevice setTorchMode:AVCaptureTorchModeOn];
//        }
        
//                if ([self.cameraDevice isFlashAvailable]) {
//                    [self.cameraDevice setFlashMode:AVCaptureFlashModeAuto];
//                }
        //解锁
        [self.cameraDevice unlockForConfiguration];
    }
}

#pragma mark -- AVCaptureVideoDataOutputSampleBufferDelegate
// 在这里处理获取的图像，并且保存每一帧到self.outputImg
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        if (output == self.videoDataOutput) { // 处理视频帧
            // 处理图片，保存到self.outputImg中
            [self imageFromSampleBuffer:sampleBuffer];
        }
    }
}
#pragma mark -- 处理图片
/**
 通过抽样缓存数据处理图像

 @param sampleBuffer 缓冲区
 @return 处理后的图片
 */
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer

{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CMVideoFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
//    self.currentVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
//    self.currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
    CIImage *result = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
//
    self.filterView.ciImage = [self fixOrientation:result];
    
    // 添加滤镜
    if (self.filter) {
        [_filter setValue:result forKey:kCIInputImageKey];
        result = _filter.outputImage;
    }
    self.currentCIImage = result;
    self.currentCIImage = [self fixOrientation:self.currentCIImage];
//    [self.mtkView draw];
    [self.mtkDelegateView setCurrentCIImage:self.currentCIImage];
    
//    NSArray* autoAdjust = [result autoAdjustmentFiltersWithOptions:nil];
//    for (CIFilter* filter in autoAdjust) {
//        NSLog(@"auto filter name:%@",[[filter attributes]valueForKey:kCIAttributeFilterName]);
//        [filter setValue: result forKey:@"inputImage"];
//        result = [filter outputImage];
//    }

    //
//    self.filterView.ciImage = [self fixOrientation:result];
//
//    // 添加滤镜
//    if (self.filter) {
//        [_filter setValue:result forKey:kCIInputImageKey];
//        result = _filter.outputImage;
//    }

//    self.ciOutputImage = result;
    

//    result = [self fixOrientation:result];
    
//    CGImageRef cgImage = [_ciContext createCGImage:result fromRect:result.extent];
//
////    CGImageRef cgImage2 = [_ciContext createCGImage:ciimage2 fromRect:ciimage2.extent];
////    self.outputImage = [[UIImage alloc] initWithCGImage:cgImage2];
//
//    // 回主线程更换处理后的图片
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.videoPreviewLayer.contents = (__bridge id)cgImage;
//        // 因为CG 结构，要自己释放
//        CGImageRelease(cgImage);
//    });
    
    return nil;
//    return self.outputImage;
    
}

-(CIImage*)fixOrientation:(CIImage*)image{
    // 处理设备旋转镜像问题
    CGAffineTransform transform;
    transform = CGAffineTransformMakeRotation(-M_PI_2);
    CIImage *result = image;
    if ([[self.cameraDeviceInput device] position] == AVCaptureDevicePositionFront) {// 前置要镜像
        result = [result imageByApplyingOrientation:UIImageOrientationUpMirrored];
    }else{
  
    }
    result = [result imageByApplyingTransform:transform];
    return result;
}


#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    
//    NSData *imageData = photo.fileDataRepresentation;
    CGImageRef imageRef = photo.CGImageRepresentation;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (imageRef) {
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:scale orientation:[self getImageOrientation]];
//        UIImage *image = [UIImage imageWithData:imageData];
        
        // Add the image to captureImageView here...
//        self.captureImageView.image = image;
        [self saveImageWithImage:image];
    }
}



#pragma mark - EPPCameraTopViewDelegate
-(void)cameraTopViewCloseTapped:(EPPCameraTopView *)view{
    [self dismiss];
}

-(void)cameraTopViewFlashTapped:(EPPCameraTopView *)view{
    if (self.flashMode == AVCaptureFlashModeAuto) {
        self.flashMode = AVCaptureFlashModeOff;
        view.flashOff = YES;
    }else{
        self.flashMode = AVCaptureFlashModeAuto;
        view.flashOff = NO;
    }
}

-(void)cameraTopViewSwitchTapped:(EPPCameraTopView *)view{
    [self changeCamera];
}

#pragma mark - EPPCameraBottomViewDelegate

-(void)cameraBottomViewCameraTapped:(EPPCameraBottomView *)view{
//    [self shutterCamera];
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecTypeJPEG}];
    settings.flashMode = self.flashMode;
    [self.stillImageOutput capturePhotoWithSettings:settings delegate:self];

    self.blackView.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.06 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.blackView.hidden = YES;
    });

}

-(void)cameraBottomViewFilterTapped:(EPPCameraBottomView *)view{
    self.filterView.hidden = !self.filterView.hidden;
}
#pragma mark - ZJSImageFilterSelectViewDelegate
-(void)imageFilterSelectView:(ZJSMTKImageFilterSelectView *)view selectImage:(CIImage *)image filterName:(NSString *)filterName{
    if (filterName && filterName.length > 0) {
        self.filter = [CIFilter filterWithName:filterName];
    } else {
        self.filter = nil;
    }
}

#pragma mark - event response
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:self.view];

    [self focusAtPoint:point];
}

#pragma mark - private methods
-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * 保存图片到相册
 */
- (void)saveImageWithImage:(UIImage *)image {
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            [self showAlertControllerWithMessage:@"保存失败,App无权限访问相册"];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            
            // 保存相片到相机胶卷
            __block PHObjectPlaceholder *createdAsset = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
            } error:&error];
            
            if (error) {
                NSLog(@"保存失败：%@", error);
                return;
            }
        });
    }];
}

- (void)showAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}




// 手动对焦
- (void)focusAtPoint:(CGPoint)point{
    [self focusAtPoint:point focusMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose];
}

- (void)focusAtPoint:(CGPoint)point focusMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode {
//    CGSize size = self.previewView.bounds.size;
    // focusPoint 函数后面Point取值范围是取景框左上角（0，0）到取景框右下角（1，1）之间,按这个来但位置就是不对，只能按上面的写法才可以。前面是点击位置的y/PreviewLayer的高度，后面是1-点击位置的x/PreviewLayer的宽度
//    CGPoint focusPoint = CGPointMake( point.y /size.height ,1 - point.x/size.width );

//    NSLog(@"focusPoint:%@",@(focusPoint));
    NSError *error = NULL;
    if ([self.cameraDevice lockForConfiguration:&error]) {
        CGPoint focusPoint = [self captureDevicePointForPoint:point];
        NSLog(@"focusPoint2:%@",@(focusPoint));
        if ([self.cameraDevice isFocusModeSupported:focusMode]) {
            [self.cameraDevice setFocusPointOfInterest:focusPoint];
            [self.cameraDevice setFocusMode:focusMode];
        }

        if ([self.cameraDevice isExposureModeSupported:exposureMode]) {
            [self.cameraDevice setExposurePointOfInterest:focusPoint];
            //曝光量调节
            [self.cameraDevice setExposureMode:exposureMode];
        }

        [self.cameraDevice unlockForConfiguration];

        self.focusView.center = point;
        self.focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self->_focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self->_focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self->_focusView.hidden = YES;
            }];
        }];
    }
    NSLog(@"error:%@",error.description);
}

// 将屏幕坐标系的点转换为previewLayer坐标系的点
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    return CGPointMake(0.5, 0.5);
//    return [self.videoPreviewLayer captureDevicePointOfInterestForPoint:point];
}

/// 摄像头切换
- (void)changeCamera {
    AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    
    //摄像头小于等于1的时候直接返回
    if (deviceDiscoverySession.devices.count <= 1) return;
    
    // 获取当前相机的方向(前还是后)
    AVCaptureDevicePosition position = [[self.cameraDeviceInput device] position];
    
    //为摄像头的转换加转场动画
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5;
    animation.type = @"oglFlip";
    
    AVCaptureDevice *newCamera = nil;
    if (position == AVCaptureDevicePositionFront) {
        //获取后置摄像头
//        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        newCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        animation.subtype = kCATransitionFromLeft;
    } else {
        //获取前置摄像头
//        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        newCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        animation.subtype = kCATransitionFromRight;
    }
    
    [self.previewView.layer addAnimation:animation forKey:nil];
    
    self.cameraDevice = newCamera;
    //输入流
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    
    if (newInput != nil) {
        [self.captureSession beginConfiguration];
        //先移除原来的input
        [self.captureSession removeInput:self.cameraDeviceInput];
        if ([self.captureSession canAddInput:newInput]) {
            [self.captureSession addInput:newInput];
            self.cameraDeviceInput = newInput;
            
        } else {
            [self.captureSession addInput:self.cameraDeviceInput];
        }
        [self.captureSession commitConfiguration];
    
        [self cameraSetting];
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification{

//    [self focusAtPoint:point];
    NSLog(@"subjectAreaDidChange");
    // 恢复到自动持续对焦，持续自动白平衡
    [self focusAtPoint:self.previewView.center focusMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure];
//    //先进行判断是否支持控制对焦
//      if (self.cameraDevice.isFocusPointOfInterestSupported &&[self.cameraDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
//
//          [self focusAtPoint:self.previewView.center focusMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure];
////          CGPoint point = [self.view convertPoint:self.focusView.center toView:self.view];
////          NSError *error =nil;
////          //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
////          [self.cameraDevice lockForConfiguration:&error];
////          [self.cameraDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
////          [self focusAtPoint:self.view.center];
////          //操作完成后，记得进行unlock。
////          [self.cameraDevice unlockForConfiguration];
//      }else{
//
//      }
}



#pragma mark - fix image orientation

-(UIImageOrientation)getImageOrientation{
    if ([[self.cameraDeviceInput device] position] == AVCaptureDevicePositionFront) {// 前置要镜像
        return [self getFrontCameraImageOrientation];
    }else{
        return [self getBackCameraImageOrientation];
    }
}

-(UIImageOrientation)getBackCameraImageOrientation{
    UIImageOrientation orientation = UIImageOrientationRight;
    // 设备方向
    UIDevice *device = [UIDevice currentDevice] ;
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左橫置");
           orientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            orientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            orientation = UIImageOrientationLeft;
            break;
    }
    return orientation;
}


-(UIImageOrientation)getFrontCameraImageOrientation{
    UIImageOrientation orientation = UIImageOrientationLeftMirrored;
    // 设备方向
    UIDevice *device = [UIDevice currentDevice] ;
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左橫置");
            orientation = UIImageOrientationDownMirrored;
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            orientation = UIImageOrientationUpMirrored;
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            orientation = UIImageOrientationRightMirrored;
            break;
    }
    return orientation;
}

#pragma mark - getters and setters

-(EPPCameraTopView *)topView{
    if (!_topView) {
        _topView = [[EPPCameraTopView alloc] init];
        _topView.delegate = self;
    }
    return _topView;
}

-(EPPCameraBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[EPPCameraBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

-(UIView *)previewView{
    if (!_previewView) {
        _previewView = [[UIView alloc] init];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
        [_previewView addGestureRecognizer:tapGesture];
    }
    return _previewView;
}

-(UIView *)focusView{
    if (!_focusView) {
        _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.layer.borderWidth = 1.0;
        _focusView.layer.borderColor = [UIColor greenColor].CGColor;
        _focusView.hidden = YES;
    }
    return _focusView;
}

-(UIView *)blackView{
    if (!_blackView) {
        _blackView = [[UIView alloc] init];
        _blackView.backgroundColor = [UIColor blackColor];
        _blackView.hidden = YES;
    }
    return _blackView;
}

-(void)setCameraDevice:(AVCaptureDevice *)cameraDevice{
    if (_cameraDevice) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_cameraDevice];
    }
    _cameraDevice = cameraDevice;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:)name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_cameraDevice];
}

-(ZJSMTKImageFilterSelectView *)filterView{
    if (!_filterView) {
        _filterView = [[ZJSMTKImageFilterSelectView alloc] init];
        _filterView.delegate = self;
    }
    return _filterView;
}


@end
