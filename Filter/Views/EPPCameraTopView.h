//
//  EPPCameraTopView.h
//  Filter
//
//  Created by 周建顺 on 2021/4/22.
//  Copyright © 2021 Hsusue. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPPCameraTopView;
NS_ASSUME_NONNULL_BEGIN

@protocol EPPCameraTopViewDelegate <NSObject>

-(void)cameraTopViewCloseTapped:(EPPCameraTopView*)view;
-(void)cameraTopViewFlashTapped:(EPPCameraTopView*)view;
-(void)cameraTopViewSwitchTapped:(EPPCameraTopView*)view;

@end

@interface EPPCameraTopView : UIView

@property (nonatomic, weak) id<EPPCameraTopViewDelegate>  delegate;
@property (nonatomic, assign) BOOL flashOff;

@end

NS_ASSUME_NONNULL_END
