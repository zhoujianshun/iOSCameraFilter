//
//  ZJSMTKDelegateView.m
//  Filter
//
//  Created by 周建顺 on 2021/4/23.
//  Copyright © 2021 Hsusue. All rights reserved.
//

#import "ZJSMTKDelegateView.h"

#import <Masonry/Masonry.h>

@interface ZJSMTKDelegateView ()<MTKViewDelegate>



@end

@implementation ZJSMTKDelegateView

#pragma mark - life cycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self addSubview:self.mtkView];
    [self.mtkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark - delegate

#pragma mark - CustomDelegate

#pragma mark - event response

#pragma mark - private methods

#pragma mark - getters and setters

-(void)setMetalDevice:(id<MTLDevice>)metalDevice{
    self.mtkView.device = metalDevice;
}

-(MTKView*)mtkView{
    if (!_mtkView) {
        _mtkView = [[MTKView alloc] initWithFrame:CGRectZero];
        _mtkView.paused = YES;
        _mtkView.enableSetNeedsDisplay = NO;
        _mtkView.delegate = self;
        _mtkView.framebufferOnly = NO;
    }
    return _mtkView;
}


#pragma mark - MTKViewDelegate

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size{
    
}

/*!
 @method drawInMTKView:
 @abstract Called on the delegate when it is asked to render into the view
 @discussion Called on the delegate when it is asked to render into the view
 */
- (void)drawInMTKView:(nonnull MTKView *)view{
    id <MTLCommandBuffer> commandBuffer =  [self.metalCommandQueue commandBuffer];
    if (commandBuffer) {
        if (self.currentCIImage) {
            id<CAMetalDrawable> currentDrawable = view.currentDrawable;
            if (currentDrawable) {
//                self.currentCIImage = [self fixOrientation:self.currentCIImage];
                CGFloat heightOfciImage = self.currentCIImage.extent.size.height;
                CGFloat heightOfDrawable = view.drawableSize.height;
//                CGFloat yOffsetFromBottom = (heightOfDrawable - heightOfciImage)/2;
                
                CGFloat yOffsetFromBottom= (heightOfDrawable+heightOfciImage)/2 ;
                
                [self.ciContext render:self.currentCIImage toMTLTexture:currentDrawable.texture commandBuffer:commandBuffer bounds:CGRectMake(0,  -yOffsetFromBottom, view.drawableSize.width, view.drawableSize.height) colorSpace:CGColorSpaceCreateDeviceRGB()];
                
                [commandBuffer presentDrawable:currentDrawable];
                [commandBuffer commit];
            }
        }
    }
}

-(void)setCurrentCIImage:(CIImage *)currentCIImage{
    _currentCIImage = currentCIImage;
    [self.mtkView draw];
}
@end
