//
//  ZJSImageFilterSelectItemCell.h
//  EPPartner
//
//  Created by 周建顺 on 2021/4/20.
//

#import <UIKit/UIKit.h>

#import "ZJSMTKImageFilterSelectItemCellViewModel.h"
#import "ZJSMTKDelegateView.h"

NS_ASSUME_NONNULL_BEGIN

#define kZJSMTKImageFilterSelectItemCellIdentify @"kZJSMTKImageFilterSelectItemCellIdentify"
@interface ZJSMTKImageFilterSelectItemCell : UICollectionViewCell

@property (nonatomic, strong) ZJSMTKImageFilterSelectItemCellViewModel *viewModel;
@property (nonatomic, strong) ZJSMTKDelegateView *imageView;
@end

NS_ASSUME_NONNULL_END
