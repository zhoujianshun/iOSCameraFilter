//
//  ZJSImageFilterSelectItemCellViewModel.h
//  EPPartner
//
//  Created by 周建顺 on 2021/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJSImageFilterSelectItemCellViewModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *filterName;
@property (nonatomic, assign) BOOL selected;

@end

NS_ASSUME_NONNULL_END
