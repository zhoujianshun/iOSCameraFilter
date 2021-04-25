//
//  ZJSMTKDelegateView.h
//  Filter
//
//  Created by 周建顺 on 2021/4/23.
//  Copyright © 2021 Hsusue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MetalKit/MTKView.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJSMTKDelegateView : UIView

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) id <MTLDevice> metalDevice;
@property (nonatomic, strong) id <MTLCommandQueue> metalCommandQueue;
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) CIImage *currentCIImage;

@end

NS_ASSUME_NONNULL_END
