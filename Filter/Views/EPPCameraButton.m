//
//  EPPCameraButton.m
//  Filter
//
//  Created by 周建顺 on 2021/4/22.
//  Copyright © 2021 Hsusue. All rights reserved.
//

#import "EPPCameraButton.h"

#import <Masonry/Masonry.h>

#import "EPPSizeFit.h"

@interface EPPCameraButton()
@property (nonatomic, strong) UIView *view;

@end

@implementation EPPCameraButton

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
    //    self.layer.masksToBounds = YES;
    //    self.layer.borderWidth = px(16);
    //    //
    self.view.backgroundColor = RGBHEXA(0x2A91FA, 1);
    self.backgroundColor = RGBHEXA(0x2A91FA, 0.4);
    
    [self addSubview:self.view];
    CGFloat padding = px(16);
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(padding, padding, padding, padding));
    }];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.layer.cornerRadius = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))/2;
    self.view.layer.cornerRadius = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))/2;
}

#pragma mark - delegate

#pragma mark - CustomDelegate

#pragma mark - event response

#pragma mark - private methods

#pragma mark - getters and setters

-(UIView *)view{
    if (!_view) {
        _view = [[UIView alloc] init];
        _view.userInteractionEnabled = NO;
        //        _view.layer
    }
    return _view;
}

@end
