//
//  EPPCameraTopView.m
//  Filter
//
//  Created by 周建顺 on 2021/4/22.
//  Copyright © 2021 Hsusue. All rights reserved.
//

#import "EPPCameraTopView.h"

#import <Masonry/Masonry.h>

#import "EPPSizeFit.h"

#import "EPPSizedImageButton.h"

@interface EPPCameraTopView()

@property (nonatomic, strong) UIView *contenView;
@property (nonatomic, strong) EPPSizedImageButton *closeButton;
@property (nonatomic, strong) EPPSizedImageButton *flashButton;
@property (nonatomic, strong) EPPSizedImageButton *switchButton;

@end

@implementation EPPCameraTopView

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
//    self.contenView.backgroundColor = [UIColor redColor];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    CGFloat top = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    top = top > 20 ? top : 0;
    [self addSubview:self.contenView];
    [self.contenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self).mas_offset(@(top));
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(60);
    }];
    
    [self.contenView addSubview:self.closeButton];
    [self.contenView addSubview:self.flashButton];
    [self.contenView addSubview:self.switchButton];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(44);
        make.leading.mas_equalTo(self.contenView).offset(8);
        make.centerY.mas_equalTo(self.contenView);
    }];
    
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(44);
        make.trailing.mas_equalTo(self.contenView).offset(-8);
        make.centerY.mas_equalTo(self.contenView);
    }];
    
    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(44);
        make.trailing.mas_equalTo(self.switchButton.mas_leading).offset(-4);
        make.centerY.mas_equalTo(self.contenView);
    }];
}

#pragma mark - delegate

#pragma mark - CustomDelegate

#pragma mark - event response

#pragma mark - private methods

#pragma mark - getters and setters

-(UIView *)contenView{
    if (!_contenView) {
        _contenView = [[UIView alloc] init];
    }
    return _contenView;
}

-(EPPSizedImageButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [[EPPSizedImageButton alloc] init];
        _closeButton.imageSize = CGSizeMake(px(48), px(48));
        _closeButton.image = [UIImage imageNamed:@"icon_camera_close"];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(EPPSizedImageButton *)flashButton{
    if (!_flashButton) {
        _flashButton = [[EPPSizedImageButton alloc] init];
        _flashButton.imageSize = CGSizeMake(px(48), px(48));
        _flashButton.image = [UIImage imageNamed:@"icon_flash"];
//        _flashButton.hidden = YES;
        [_flashButton addTarget:self action:@selector(flashAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashButton;
}

-(EPPSizedImageButton *)switchButton{
    if (!_switchButton) {
        _switchButton = [[EPPSizedImageButton alloc] init];
        _switchButton.imageSize = CGSizeMake(px(48), px(48));
        _switchButton.image = [UIImage imageNamed:@"icon_camera_switch"];
        [_switchButton addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

-(void)closeAction{
    if ([self.delegate respondsToSelector:@selector(cameraTopViewCloseTapped:)]) {
        [self.delegate cameraTopViewCloseTapped:self];
    }
}

-(void)flashAction{
    if ([self.delegate respondsToSelector:@selector(cameraTopViewFlashTapped:)]) {
        [self.delegate cameraTopViewFlashTapped:self];
    }
}

-(void)switchAction{
    if ([self.delegate respondsToSelector:@selector(cameraTopViewSwitchTapped:)]) {
        [self.delegate cameraTopViewSwitchTapped:self];
    }
}

-(void)setFlashOff:(BOOL)flashOff{
    _flashOff = flashOff;
    if (_flashOff) {
        self.flashButton.image = [UIImage imageNamed:@"icon_flash_off"];
    }else{
        self.flashButton.image = [UIImage imageNamed:@"icon_flash"];
    }
}

@end
