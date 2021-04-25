//
//  ZJSImageFilterSelectView.h
//  EPPartner
//
//  Created by 周建顺 on 2021/4/20.
//

#import <UIKit/UIKit.h>

@class ZJSMTKImageFilterSelectView;

NS_ASSUME_NONNULL_BEGIN
@protocol ZJSMTKImageFilterSelectViewDelegate <NSObject>

-(void)imageFilterSelectView:(ZJSMTKImageFilterSelectView*)view selectImage:(CIImage*)image filterName:(NSString*)filterName;

@end

@interface ZJSMTKImageFilterSelectView : UIView

@property (nonatomic, strong) id <MTLDevice> metalDevice;
@property (nonatomic, strong) id <MTLCommandQueue> metalCommandQueue;
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) CIImage *ciImage;

@property (nonatomic, copy) NSString *selectFilterName;

@property (nonatomic, weak) id<ZJSMTKImageFilterSelectViewDelegate>  delegate;
@end

NS_ASSUME_NONNULL_END
