//
//  ZJSMTKView.m
//  Filter
//
//  Created by 周建顺 on 2021/4/23.
//  Copyright © 2021 Hsusue. All rights reserved.
//

#import "ZJSMTKView.h"

@implementation ZJSMTKView

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
    self.device = MTLCreateSystemDefaultDevice();
    self.paused = YES;
    self.enableSetNeedsDisplay = NO;
 
}

#pragma mark - delegate

#pragma mark - CustomDelegate

#pragma mark - event response

#pragma mark - private methods

#pragma mark - getters and setters

@end
