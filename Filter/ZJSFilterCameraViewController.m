//
//  CustomCameraViewController.m
//  LearningProject
//
//  Created by Hsusue on 2019/5/22.
//  Copyright © 2019 Hsusue. All rights reserved.
//

#import "ZJSFilterCameraViewController.h"


#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import <Masonry.h>
#import "ZJSImageFilterSelectView.h"
#import "EPPCameraTopView.h"
#import "EPPCameraBottomView.h"

API_AVAILABLE(ios(10.0))
@interface ZJSFilterCameraViewController ()<AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, ZJSImageFilterSelectViewDelegate, EPPCameraTopViewDelegate,EPPCameraBottomViewDelegate>

// 音视频输入流
// 摄像头
@property(nonatomic, strong) AVCaptureDevice *device;
// 摄像头输入
@property(nonatomic, strong) AVCaptureDeviceInput *cameraDeviceInput;
// 音频、视频输出流
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) AVCaptureSession *session;

// 当前帧处理完的图片，实时更新
@property (nonatomic, strong) UIImage *outputImage;
@property (nonatomic, strong) CIImage *ciOutputImage;


// 当前帧的尺寸，用于录制时设置尺寸
//@property (nonatomic, assign) CMVideoDimensions currentVideoDimensions;
//@property (nonatomic, assign) CMTime currentSampleTime;

// 滤镜用到的
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) CIFilter *filter;

// ------------- UI --------------
@property (nonatomic, strong) UIButton *photoButton;

// 聚焦显示框
@property (nonatomic, strong) UIView *focusView;
// 用来响应聚焦事件
@property (nonatomic, strong) UIView *clearView;

@property (nonatomic, strong) CALayer *previewLayer;
@property (nonatomic, strong) ZJSImageFilterSelectView *filterView;

@property (nonatomic, strong) EPPCameraTopView *topView;
@property (nonatomic, strong) EPPCameraBottomView *bottomView;
//@property (nonatomic, assign) BOOL isShootStatus;
@property (nonatomic, strong) UIView *blackView;

@property (nonatomic, assign) BOOL shutting;

@end

@implementation ZJSFilterCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self customCamera];
    [self initSubViews];
    
//    [self focusAtPoint:CGPointMake(0.5, 0.5)];
    
//    self.isShootStatus = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([_session isRunning]) {
        [_session stopRunning];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.focusView.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2 - 60);
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    _previewLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)customCamera
{
//    _ciContext = [[CIContext alloc]init];
    _ciContext = [CIContext contextWithOptions:nil];
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    
    _queue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    [_videoDataOutput setSampleBufferDelegate:self queue:_queue];
    

    _session = [[AVCaptureSession alloc] init];
    if ([_session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        [_session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    
    { // 把输入输出结合起来
        if ([_session canAddInput:_cameraDeviceInput]) {
            [_session addInput:_cameraDeviceInput];
        }
        if ([_session canAddOutput:_videoDataOutput]) {
            [_session addOutput:_videoDataOutput];
        }
    }
    
    
    //开始启动
    [_session startRunning];
    
    //修改设备的属性，先加锁
    if ([_device lockForConfiguration:nil]) {
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        _device.subjectAreaChangeMonitoringEnabled = YES;
//        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
//            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
//        }
        //解锁
        [_device unlockForConfiguration];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:)name:AVCaptureDeviceSubjectAreaDidChangeNotification object:_device];
 
}
- (void)subjectAreaDidChange:(NSNotification *)notification{

//    [self focusAtPoint:point];
    NSLog(@"subjectAreaDidChange");
    //先进行判断是否支持控制对焦
      if (_device.isFocusPointOfInterestSupported &&[_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//          CGPoint point = [self.view convertPoint:self.focusView.center toView:self.view];
          NSError *error =nil;
          //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
          [_device lockForConfiguration:&error];
          [_device setFocusMode:AVCaptureFocusModeAutoFocus];
          [self focusAtPoint:self.view.center];
          //操作完成后，记得进行unlock。
          [_device unlockForConfiguration];
      }
}

- (void)initSubViews
{
    self.view.backgroundColor = [UIColor blackColor];
    
    _previewLayer = [[CALayer alloc] init];
    _previewLayer.anchorPoint = CGPointZero;
//    _previewLayer.frame = CGRectMake(0, kTopMargin + 50, KScreenWidth, KScreenHeight - 100 - kBottomMargin - 50);
    [self.view.layer addSublayer:_previewLayer];
    

    
//    UIView *bottomBlackView = [[UIView alloc] init];
//    bottomBlackView.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:bottomBlackView];
//    [bottomBlackView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(self.view);
//        make.height.equalTo(@(100 + kBottomMargin));
//    }];
    

    
//    self.photoButton = [UIButton new];
//    [self.photoButton setBackgroundImage:[UIImage imageNamed:@"shoot"] forState:UIControlStateNormal];
//    [self.photoButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
//    [bottomBlackView addSubview:self.photoButton];
//    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(bottomBlackView);
//        make.top.equalTo(bottomBlackView).offset(20);
//        make.width.height.equalTo(@60);
//    }];
//    

    
//    UIButton *changeCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [changeCameraBtn setBackgroundImage:[UIImage imageNamed:@"changeCamera"] forState:UIControlStateNormal];
//    changeCameraBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [changeCameraBtn sizeToFit];
//    [changeCameraBtn addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
//    [bottomBlackView addSubview:changeCameraBtn];
//    [changeCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).offset(-(20 + kBottomMargin));
//        make.width.height.equalTo(@40);
//        make.right.equalTo(self.view).offset(-20);
//    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    UIView *clearView = [[UIView alloc] init];
    clearView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:clearView];
    [clearView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [clearView addGestureRecognizer:tapGesture];
    self.clearView = clearView;
    
    [self.clearView addSubview:self.blackView];
    [self.blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.focusView.layer.borderWidth = 1.0;
    self.focusView.layer.borderColor = [UIColor greenColor].CGColor;
    [self.clearView addSubview:self.focusView];
    self.focusView.hidden = YES;


    _filterView = [[ZJSImageFilterSelectView alloc] init];
    _filterView.delegate = self;
    _filterView.hidden = YES;
    
    [self.view addSubview:_filterView];
    [self.view addSubview:self.bottomView];
    
    [_filterView mas_makeConstraints:^(MASConstraintMaker *make) {
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
}

- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];

    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.clearView.bounds.size;
    // focusPoint 函数后面Point取值范围是取景框左上角（0，0）到取景框右下角（1，1）之间,按这个来但位置就是不对，只能按上面的写法才可以。前面是点击位置的y/PreviewLayer的高度，后面是1-点击位置的x/PreviewLayer的宽度
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1 - point.x/size.width );
    
    if ([self.device lockForConfiguration:nil]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [self.device setExposurePointOfInterest:focusPoint];
            //曝光量调节
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        
        _focusView.center = point;
        _focusView.hidden = NO;
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

#pragma mark - ZJSImageFilterSelectViewDelegate
-(void)imageFilterSelectView:(ZJSImageFilterSelectView *)view selectImage:(UIImage *)image filterName:(NSString *)filterName{
    if (filterName && filterName.length > 0) {
        self.filter = [CIFilter filterWithName:filterName];
    } else {
        self.filter = nil;
    }
}

#pragma mark - EPPCameraTopViewDelegate
-(void)cameraTopViewCloseTapped:(EPPCameraTopView *)view{
    [self dismiss];
}

-(void)cameraTopViewFlashTapped:(EPPCameraTopView *)view{
    
}

-(void)cameraTopViewSwitchTapped:(EPPCameraTopView *)view{
    [self changeCamera];
}

#pragma mark - EPPCameraBottomViewDelegate

-(void)cameraBottomViewCameraTapped:(EPPCameraBottomView *)view{
    [self shutterCamera];
}

-(void)cameraBottomViewFilterTapped:(EPPCameraBottomView *)view{
    self.filterView.hidden = !self.filterView.hidden;
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
    
//    NSArray* autoAdjust = [result autoAdjustmentFiltersWithOptions:nil];
//    for (CIFilter* filter in autoAdjust) {
//        NSLog(@"auto filter name:%@",[[filter attributes]valueForKey:kCIAttributeFilterName]);
//        [filter setValue: result forKey:@"inputImage"];
//        result = [filter outputImage];
//    }

    //
    self.filterView.ciImage = [self fixOrientation:result];
    
    // 添加滤镜
    if (self.filter) {
        [_filter setValue:result forKey:kCIInputImageKey];
        result = _filter.outputImage;
    }
    
    self.ciOutputImage = result;
    

    result = [self fixOrientation:result];
    
    CGImageRef cgImage = [_ciContext createCGImage:result fromRect:result.extent];
    
//    CGImageRef cgImage2 = [_ciContext createCGImage:ciimage2 fromRect:ciimage2.extent];
//    self.outputImage = [[UIImage alloc] initWithCGImage:cgImage2];
    
    // 回主线程更换处理后的图片
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewLayer.contents = (__bridge id)cgImage;
        // 因为CG 结构，要自己释放
        CGImageRelease(cgImage);
    });
    
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


#pragma mark- 按钮事件
- (void)shutterCamera
{
    if (self.shutting ) {
        return;
    }
    self.shutting = YES;
    self.blackView.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.06 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.blackView.hidden = YES;
        self.shutting = NO;
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self.session stopRunning];
        
            UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
            CGAffineTransform transform;
        
        if ([[self.cameraDeviceInput device] position] == AVCaptureDevicePositionFront) {// 前置要镜像
            self.ciOutputImage = [self.ciOutputImage imageByApplyingOrientation:UIImageOrientationDownMirrored];
            if (orientation == UIDeviceOrientationLandscapeLeft) {
                transform = CGAffineTransformMakeRotation(M_PI_2);
            } else if (orientation == UIDeviceOrientationLandscapeRight) {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
            } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
                transform = CGAffineTransformMakeRotation(M_PI);
            }else if (orientation == UIDeviceOrientationPortrait) {
                transform = CGAffineTransformMakeRotation(0.0);
            } else {
                transform = CGAffineTransformMakeRotation(0.0);
            }
        }else{
            if (orientation == UIDeviceOrientationPortrait) {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                NSLog(@"orientation:%@", @"UIDeviceOrientationPortrait");
            }
            else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
                transform = CGAffineTransformMakeRotation(M_PI_2);
                NSLog(@"orientation:%@",@"UIDeviceOrientationPortraitUpsideDown");
            }
            else if (orientation == UIDeviceOrientationLandscapeRight) {
                transform = CGAffineTransformMakeRotation(M_PI);
                NSLog(@"orientation:%@",@"UIDeviceOrientationLandscapeRight");
            }
            else if (orientation == UIDeviceOrientationLandscapeLeft) {
                transform = CGAffineTransformMakeRotation(0.0);
                NSLog(@"orientation:%@",@"UIDeviceOrientationLandscapeLeft");
            }  else if (orientation == UIDeviceOrientationFaceUp) {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                NSLog(@"orientation:%@",@"UIDeviceOrientationFaceUp");
            }  else if (orientation == UIDeviceOrientationFaceDown) {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                NSLog(@"orientation:%@",@"UIDeviceOrientationFaceDown");
            }
            else {
                NSLog(@"orientation:%@",@"other");
                transform = CGAffineTransformMakeRotation(-M_PI_2);
            }
            
        }

//        NSArray* autoAdjust = [ self.ciOutputImage autoAdjustmentFiltersWithOptions:nil];
//        for (CIFilter* filter in autoAdjust) {
//            NSLog(@"auto filter name:%@",[[filter attributes]valueForKey:kCIAttributeFilterName]);
//            [filter setValue: self.ciOutputImage forKey:@"inputImage"];
//            self.ciOutputImage = [filter outputImage];
//        }
      
        self.ciOutputImage = [self.ciOutputImage imageByApplyingTransform:transform];
        CGImageRef cgImage = [self.ciContext createCGImage:self.ciOutputImage fromRect:self.ciOutputImage.extent];
        UIImage *image = [[UIImage alloc] initWithCGImage:cgImage];
 
        // 回主线程更换处理后的图片
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveImageWithImage:image];
            // 因为CG 结构，要自己释放
            CGImageRelease(cgImage);
//            [self.session startRunning];
        });
    });
//    [self saveImageWithImage:self.outputImage];
  
}


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
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        animation.subtype = kCATransitionFromLeft;
    } else {
        //获取前置摄像头
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        animation.subtype = kCATransitionFromRight;
    }
    
    [self.previewLayer addAnimation:animation forKey:nil];
    
    //输入流
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    
    if (newInput != nil) {
        [self.session beginConfiguration];
        //先移除原来的input
        [self.session removeInput:self.cameraDeviceInput];
        if ([self.session canAddInput:newInput]) {
            [self.session addInput:newInput];
            self.cameraDeviceInput = newInput;
            
        } else {
            [self.session addInput:self.cameraDeviceInput];
        }
        [self.session commitConfiguration];
    }
}


#pragma mark -- private method


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    for ( AVCaptureDevice *device in deviceDiscoverySession.devices )
        if ( device.position == position ) return device;
    return nil;
}

- (void)showAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -- 懒加载

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

-(UIView *)blackView{
    if (!_blackView) {
        _blackView = [[UIView alloc] init];
        _blackView.backgroundColor = [UIColor blackColor];
        _blackView.hidden = YES;
    }
    return _blackView;
}

@end
