//
//  EPPSizedImageButton.h
//  EPPartner
//
//  Created by 周建顺 on 2021/4/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPPSizedImageButton : UIControl

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
