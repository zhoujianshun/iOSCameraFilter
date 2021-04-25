//
//  ZJSImageFilterSelectView.h
//  EPPartner
//
//  Created by 周建顺 on 2021/4/20.
//

#import <UIKit/UIKit.h>

@class ZJSImageFilterSelectView;

NS_ASSUME_NONNULL_BEGIN
@protocol ZJSImageFilterSelectViewDelegate <NSObject>

-(void)imageFilterSelectView:(ZJSImageFilterSelectView*)view selectImage:(UIImage*)image filterName:(NSString*)filterName;

@end

@interface ZJSImageFilterSelectView : UIView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CIImage *ciImage;
//@property (nonatomic, strong) UIImage *filterImage;
@property (nonatomic, copy) NSString *selectFilterName;

@property (nonatomic, weak) id<ZJSImageFilterSelectViewDelegate>  delegate;
@end

NS_ASSUME_NONNULL_END
