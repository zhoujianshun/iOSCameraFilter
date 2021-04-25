//
//  EPPCameraBottomView.m
//  Filter
//
//  Created by 周建顺 on 2021/4/22.
//  Copyright © 2021 Hsusue. All rights reserved.
//

#import "EPPCameraBottomView.h"

#import <Masonry/Masonry.h>

#import "EPPSizeFit.h"

#import "EPPCameraButton.h"
#import "EPPButton.h"

@interface EPPCameraBottomView ()

@property (nonatomic, strong) EPPCameraButton *cameraButton;
@property (nonatomic, strong) EPPButton *filterButton;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation EPPCameraBottomView
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
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    CGFloat bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(0, 0, bottom, 0));
        make.height.mas_equalTo(px(180));
    }];
    
    [self.contentView addSubview:self.cameraButton];
    [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_equalTo(px(120));
    }];
    
    [self.contentView addSubview:self.filterButton];
    [self.filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.cameraButton);
        make.trailing.mas_equalTo(self.cameraButton.mas_leading).offset(-px(140));
    }];
}

#pragma mark - delegate

#pragma mark - CustomDelegate

#pragma mark - event response
-(void)cameraAction{
    if ([self.delegate respondsToSelector:@selector(cameraBottomViewCameraTapped:)]) {
        [self.delegate cameraBottomViewCameraTapped:self];
    }
}

-(void)filtterAction{
    if ([self.delegate respondsToSelector:@selector(cameraBottomViewFilterTapped:)]) {
        [self.delegate cameraBottomViewFilterTapped:self];
    }
}

#pragma mark - private methods

#pragma mark - getters and setters

-(EPPCameraButton *)cameraButton{
    if (!_cameraButton) {
        _cameraButton = [[EPPCameraButton alloc] init];
        [_cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

-(EPPButton *)filterButton{
    if (!_filterButton) {
        _filterButton = [[EPPButton alloc] init];
        _filterButton.title = @"滤镜";
        _filterButton.axis = UILayoutConstraintAxisVertical;
        _filterButton.spacing = px(10);
        _filterButton.image = [UIImage imageNamed:@"icon_filter"];
        _filterButton.iconSize = px(48);
        _filterButton.titleLabel.font = [UIFont systemFontOfSize:px(28) weight:UIFontWeightMedium];
        _filterButton.titleLabel.textColor = [UIColor whiteColor];
        [_filterButton addTarget:self action:@selector(filtterAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterButton;
}

@end
