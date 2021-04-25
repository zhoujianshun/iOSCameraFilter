//
//  EPPVButton.m
//  EPPartner
//
//  Created by 周建顺 on 2021/4/2.
//

#import "EPPButton.h"

#import <Masonry/Masonry.h>

#import "EPPSizeFit.h"

@interface EPPButton ()

@property (nonatomic, strong) UIStackView *contentWrapper;

@end

@implementation EPPButton

@synthesize iconImageView = _iconImageView;
@synthesize titleLabel = _titleLabel;

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
//    self.backgroundColor = [UIColor purpleColor];
    [self addSubview:self.contentWrapper];

    [self.contentWrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self).priorityHigh();
        make.edges.mas_lessThanOrEqualTo(self).priorityLow();
    }];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(40);
    }];
}



#pragma mark - delegate

#pragma mark - CustomDelegate

#pragma mark - event response

#pragma mark - private methods

#pragma mark - getters and setters

-(UIStackView *)contentWrapper{
    if (!_contentWrapper) {
        _contentWrapper = [[UIStackView alloc] initWithArrangedSubviews:@[self.iconImageView, self.titleLabel]];
        _contentWrapper.axis = UILayoutConstraintAxisHorizontal;
        _contentWrapper.spacing = 8;
        _contentWrapper.userInteractionEnabled = false; // 防止无法点击
        _contentWrapper.alignment = UIStackViewAlignmentCenter;
//        _contentWrapper.distribution = UIStackViewDistributionFillProportionally;
    }
    return _contentWrapper;
}

-(UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return  _iconImageView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
//        [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _titleLabel;
}

-(void)setIconSize:(CGFloat)iconSize{
    _iconSize = iconSize;
    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(iconSize);
    }];
}

-(void)setSpacing:(CGFloat)spacing{
    self.contentWrapper.spacing = spacing;
}

-(CGFloat)spacing{
    return self.contentWrapper.spacing;
}

-(void)setAxis:(UILayoutConstraintAxis)axis{
    self.contentWrapper.axis = axis;
}

-(UILayoutConstraintAxis)axis{
    return self.contentWrapper.axis;
}

-(void)setContentInsets:(UIEdgeInsets)contentInsets{
    _contentInsets = contentInsets;
    [self.contentWrapper mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(contentInsets);
    }];
}
-(void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}

-(NSString *)title{
    return self.titleLabel.text;
}

-(void)setImage:(UIImage *)image{
    self.iconImageView.image = image;
}

-(UIImage *)image{
    return self.iconImageView.image;
}

@end
