//
//  ZJSImageFilterSelectItemCell.h
//  EPPartner
//
//  Created by 周建顺 on 2021/4/20.
//

#import <UIKit/UIKit.h>

#import "ZJSImageFilterSelectItemCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

#define kZJSImageFilterSelectItemCellIdentify @"kZJSImageFilterSelectItemCellIdentify"
@interface ZJSImageFilterSelectItemCell : UICollectionViewCell

@property (nonatomic, strong) ZJSImageFilterSelectItemCellViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
