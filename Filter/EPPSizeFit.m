//
//  EPPSizeFit.m
//  EPPartner
//
//  Created by 周建顺 on 2021/3/23.
//

#import "EPPSizeFit.h"

@interface EPPSizeFit()

@property (nonatomic, assign) CGFloat standardSize;
@property (nonatomic, assign) CGFloat scale;

@end

@implementation EPPSizeFit

- (instancetype)initWithStandardSize:(CGFloat)standardSize
{
    self = [super init];
    if (self) {
        
        [self setupWithStandardSize:standardSize];
    }
    return self;
}

-(instancetype)init
{
    return [self initWithStandardSize:750];
}

+ (instancetype)sharedInstanceWithStandardSize:(CGFloat)standardSize
{
    static EPPSizeFit *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[self.class alloc] initWithStandardSize:standardSize];
        }
    });
    return manager;
}
  
+ (instancetype)sharedInstance
{
    return [self sharedInstanceWithStandardSize:750];
}


+ (CGFloat)px:(CGFloat)px{

//    return  [self.sharedInstance sizeWithPx:px];
    if (SCREEN_MIN_LENGTH >= 750/2) {
        return px / 2;
    }else{
        return  [self.sharedInstance sizeWithPx:px];
    }
}

+ (CGFloat)pxFit:(CGFloat)px{
    return  [self.sharedInstance sizeWithPx:px];
}

+ (CGFloat)pt:(CGFloat)pt{
    if (SCREEN_MIN_LENGTH >= 750/2) {
        return pt;
    }else{
        return  [self.sharedInstance sizeWithPt:pt] ;
    }
}

-(void)setupWithStandardSize:(CGFloat)standardSize{
    _standardSize = standardSize;
    CGFloat screenWidth = SCREEN_MIN_LENGTH;
    _scale =  screenWidth / _standardSize * 2;
}

-(CGFloat)sizeWithPx:(CGFloat)px{
    return _scale*px / 2;
}

-(CGFloat)sizeWithPt:(CGFloat)pt{
    return _scale*pt;
}


@end
