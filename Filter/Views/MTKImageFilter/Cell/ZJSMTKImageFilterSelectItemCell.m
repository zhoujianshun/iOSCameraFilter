//
//  ZJSImageFilterSelectItemCell.m
//  EPPartner
//
//  Created by 周建顺 on 2021/4/20.
//

#import "ZJSMTKImageFilterSelectItemCell.h"
#import <Masonry/Masonry.h>

#import "EPPSizeFit.h"
#import "ZJSMTKDelegateView.h"

#define kImageFilterSelectItemCellDotCornerRadius 5
@interface ZJSMTKImageFilterSelectItemCell()


@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIView *dotView;

@end

@implementation ZJSMTKImageFilterSelectItemCell

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

-(void)dealloc{
    [_viewModel removeObserver:self forKeyPath:@"currentCIImage"];
}

- (void)commonInit {
//    self.contentView.layer.cornerRadius = 10;
//    self.contentView.layer.borderWidth = 2;
//    self.contentView.layer.borderColor = [UIColor blueColor].CGColor;
    self.contentView.layer.masksToBounds = YES;
    
    
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
    }];
    
    [self addSubview:self.dotView];
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.mas_top).offset(-10);
        make.size.mas_equalTo(10);
    }];
}
#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentCIImage"]) {
        [self refreshImage];
    }
}

#pragma mark - CustomDelegate

#pragma mark - event response

#pragma mark - private methods
-(void)refreshImage{
    CIImage *result = _viewModel.currentCIImage;
//    if (_viewModel.filter) {
//        [_viewModel.filter setValue:result forKey:kCIInputImageKey];
//        result = _viewModel.filter.outputImage;
//    }
    self.imageView.currentCIImage = result;
}


#pragma mark - getters and setters

-(void)setViewModel:(ZJSMTKImageFilterSelectItemCellViewModel *)viewModel{
    [_viewModel removeObserver:self forKeyPath:@"currentCIImage"];
    
    _viewModel = viewModel;
//    self.label.text = _viewModel.title;
//    self.imageView.image = viewModel.image;
    self.imageView.metalDevice = viewModel.metalDevice;
    self.imageView.metalCommandQueue = viewModel.metalCommandQueue;
    self.imageView.ciContext = viewModel.ciContext;
   
    [self refreshImage];
    
    self.dotView.hidden = !_viewModel.selected;
    
    [_viewModel addObserver:self forKeyPath:@"currentCIImage" options:NSKeyValueObservingOptionNew context:NULL];
    
//    self.label.text = self.viewModel.selected ? @"current":@"";
}

-(UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc] init];
    }
    return _label;
}

-(ZJSMTKDelegateView *)imageView{
    if (!_imageView) {
        _imageView = [[ZJSMTKDelegateView alloc] init];
//        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

-(UIView *)dotView{
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.backgroundColor = [UIColor whiteColor];
        _dotView.layer.cornerRadius = kImageFilterSelectItemCellDotCornerRadius;
        _dotView.layer.masksToBounds = YES;
    }
    return _dotView;
}

@end
