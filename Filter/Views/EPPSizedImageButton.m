//
//  EPPSizedImageButton.m
//  EPPartner
//
//  Created by 周建顺 on 2021/4/17.
//

#import "EPPSizedImageButton.h"
#import <Masonry/Masonry.h>

@interface EPPSizedImageButton ()

@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation EPPSizedImageButton

#pragma mark - life cycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self epp_sizeed_image_commonInit];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self epp_sizeed_image_commonInit];
    }
    return self;
}

- (void)epp_sizeed_image_commonInit {
    [self addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_lessThanOrEqualTo(self).priorityLow();
    }];
}

#pragma mark - delegate

#pragma mark - CustomDelegate

#pragma mark - event response

#pragma mark - private methods

#pragma mark - getters and setters

-(UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.userInteractionEnabled = NO;
    }
    return _iconImageView;
}

-(void)setImageSize:(CGSize)imageSize{
    _imageSize = imageSize;
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(imageSize.width);
        make.height.mas_equalTo(imageSize.height);
    }];
}

-(void)setImage:(UIImage *)image{
    self.iconImageView.image = image;
}

-(UIImage *)image{
    return self.iconImageView.image;
}

@end
