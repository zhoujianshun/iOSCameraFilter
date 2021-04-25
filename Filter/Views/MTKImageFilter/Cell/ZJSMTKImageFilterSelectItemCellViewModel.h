//
//  ZJSImageFilterSelectItemCellViewModel.h
//  EPPartner
//
//  Created by 周建顺 on 2021/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJSMTKImageFilterSelectItemCellViewModel : NSObject

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) NSString *filterName;

//@property (nonatomic, copy) CIFilter *filter;
@property (nonatomic, strong) id <MTLDevice> metalDevice;
@property (nonatomic, strong) id <MTLCommandQueue> metalCommandQueue;
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) CIImage *currentCIImage;

@end

NS_ASSUME_NONNULL_END
