//
//  EPPSizeFit.h
//  EPPartner
//
//  Created by 周建顺 on 2021/3/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define pt(ptv) [EPPSizeFit pt:ptv]
#define px(pxv) [EPPSizeFit px:pxv]
#define pxFit(pxv) [EPPSizeFit pxFit:pxv]


#define ptnum(ptv) @([EPPSizeFit pt:ptv])
#define pxnum(pxv) @([EPPSizeFit px:pxv])

@interface EPPSizeFit : NSObject

+ (instancetype)sharedInstanceWithStandardSize:(CGFloat)standardSize;
+ (instancetype)sharedInstance;

-(void)setupWithStandardSize:(CGFloat)standardSize;

+ (CGFloat)px:(CGFloat)px;
+ (CGFloat)pt:(CGFloat)pt;

+ (CGFloat)pxFit:(CGFloat)px;
@end

NS_ASSUME_NONNULL_END
