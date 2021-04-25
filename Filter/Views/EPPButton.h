//
//  EPPVButton.h
//  EPPartner
//
//  Created by 周建顺 on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/// 可以设置图片大小的按钮
@interface EPPButton : UIControl

@property (nonatomic, assign) CGFloat iconSize;
@property (nonatomic, strong, readonly) UIImageView *iconImageView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CGFloat spacing;
@property(nonatomic) UILayoutConstraintAxis axis;
@property (nonatomic) UIEdgeInsets contentInsets;

@end

NS_ASSUME_NONNULL_END
