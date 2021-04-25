//
//  ZJSImageFilterSelectView.m
//  EPPartner
//
//  Created by 周建顺 on 2021/4/20.
//

#import "ZJSImageFilterSelectView.h"

#import <Masonry/Masonry.h>

#import "EPPSizeFit.h"

#import "ZJSImageFilterSelectItemCell.h"

#define kZJSImageFilterSelectItemCellHeight  px(120)
#define kZJSImageFilterSelectItemCellBoundBorderWidth px(7)
@interface ZJSImageFilterSelectView ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<ZJSImageFilterSelectItemCellViewModel*> *datas;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UIView *boundView;
@property (nonatomic, strong) UIView *labelWrapper;
@property (nonatomic, strong) UILabel *label;


@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSIndexPath *targetIndex;
@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, copy) NSArray *nameArray;
@property (nonatomic, copy) NSDictionary *dict;
@property (nonatomic, assign) BOOL loaded;

@property (nonatomic, strong) CIContext * ciContext;
@end

@implementation ZJSImageFilterSelectView

#pragma mark - life cycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (void)commonInit {
    self.ciContext = [CIContext contextWithOptions:nil];
    
//NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
//[options setObject: [NSNull null] forKey: kCIContextWorkingColorSpace];
//CIContext* context =  [CIContext contextWithEAGLContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] options:options];
//    self.ciContext = context;
//
    
    [self addSubview:self.labelWrapper];
    [self.labelWrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
    
    }];
    
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.top.mas_equalTo(self.labelWrapper.mas_bottom).offset(px(60));
        make.bottom.mas_equalTo(self).offset(-kZJSImageFilterSelectItemCellBoundBorderWidth);
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.height.mas_equalTo(kZJSImageFilterSelectItemCellHeight);
    }];
    
    [self addSubview:self.boundView];
    [self.boundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(kZJSImageFilterSelectItemCellHeight +  kZJSImageFilterSelectItemCellBoundBorderWidth*2 );
        make.center.mas_equalTo(self.collectionView);
    }];

    [self initDatas];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat padding = CGRectGetWidth(self.frame)/2 - kZJSImageFilterSelectItemCellHeight/2;
    self.layout.sectionInset = UIEdgeInsetsMake(0, padding , 0, padding);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.datas ? self.datas.count : 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZJSImageFilterSelectItemCellViewModel *baseVM = [self.datas objectAtIndex:indexPath.item];
    
    ZJSImageFilterSelectItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZJSImageFilterSelectItemCellIdentify forIndexPath:indexPath];
    cell.viewModel = (ZJSImageFilterSelectItemCellViewModel*)baseVM;
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    //    ZJSCollectionViewGroupBaseViewModel *group = [self.groups objectAtIndex:indexPath.section];
    //    ZJSCollectionViewCellBaseViewModel *baseVM = [group.datas objectAtIndex:indexPath.item];
    //
    return CGSizeMake(kZJSImageFilterSelectItemCellHeight, kZJSImageFilterSelectItemCellHeight);
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    CGFloat space = px(0);
//    return  UIEdgeInsetsMake(space, space,  space, space);
//}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 3;
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    return px(30);
//}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    ZJSImageFilterSelectItemCellViewModel *baseVM = [self.datas objectAtIndex:indexPath.item];
    //    [baseVM cellTappedAction];
//    DLOG_METHOD
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    self.targetIndex = indexPath;
}
//
//- (CGPoint)nearestTargetOffsetForOffset:(CGPoint)offset
//{
//    CGFloat pageSize = kZJSImageFilterSelectItemCellHeight + 0.01;
//    NSInteger page = roundf(offset.x / pageSize);
//    CGFloat targetX = pageSize * page;
//    return CGPointMake(targetX, offset.y);
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    CGPoint targetOffset = [self nearestTargetOffsetForOffset:*targetContentOffset];
//    targetContentOffset->x = targetOffset.x;
//    targetContentOffset->y = targetOffset.y;
//}

// UIScrollView的delegate方法妙用之让UICollectionView滑动到某个你想要的位置
// https://www.cnblogs.com/Phelthas/p/4584645.html
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint originalTargetContentOffset = CGPointMake(targetContentOffset->x, targetContentOffset->y);
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    //    width = kZJSImageFilterSelectItemCellHeight;
    CGPoint targetCenter = CGPointMake(originalTargetContentOffset.x + width/2, CGRectGetHeight(self.collectionView.bounds) / 2);
    NSIndexPath *indexPath = nil;
    NSInteger i = 0;
    while (indexPath == nil && i < self.datas.count) {
        targetCenter = CGPointMake(originalTargetContentOffset.x + width/2 + i * 3, CGRectGetHeight(self.collectionView.bounds) / 2);
        indexPath = [self.collectionView indexPathForItemAtPoint:targetCenter];
        i++;
    }
    if (indexPath == nil) {
        indexPath = [NSIndexPath indexPathForItem:self.datas.count - 1 inSection:0];
    }
    self.targetIndex = indexPath;
    //这里用attributes比用cell要好很多，因为cell可能因为不在屏幕范围内导致cellForItemAtIndexPath返回nil
    UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    if (attributes) {
        *targetContentOffset = CGPointMake(attributes.center.x - width/2, originalTargetContentOffset.y);
    } else {
//        DLog(@"center is %@; indexPath is {%@, %@}; cell is %@",NSStringFromCGPoint(targetCenter), @(indexPath.section), @(indexPath.item), attributes);
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageSize = kZJSImageFilterSelectItemCellHeight + 2;
    NSInteger page = roundf(scrollView.contentOffset.x / pageSize);
    //        CGFloat targetX = pageSize * page;
    if (page < 0) {
        page = 0;
    }
    
    if (page >= self.datas.count) {
        page = self.datas.count - 1;
    }
    
    self.currentIndex = page;
    
}
#pragma mark - CustomDelegate

#pragma mark - event response

#pragma mark - private methods

-(void)initDatas{

    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.nameArray.count; i ++) {
        ZJSImageFilterSelectItemCellViewModel *vm = [[ZJSImageFilterSelectItemCellViewModel alloc] init];
        NSString *filterName = self.dict[self.nameArray[i]];
        vm.filterName = filterName;

        [array addObject:vm];
    }
    self.datas = array;
}
- (void)requestData{
    
    if (!self.image && !self.ciImage) {
        return;
    }


    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL hasSelect = NO;
        NSUInteger selectIndex = 0;

        for (int i = 0; i < self.nameArray.count; i ++) {
            ZJSImageFilterSelectItemCellViewModel *vm = self.datas[i];
            NSString *filterName = self.dict[self.nameArray[i]];
            if (self.image) {
                vm.image = [self filterImage: self.image name:filterName];
            }else if(self.ciImage){
                vm.image = [self filterCIImage:self.ciImage name:filterName];
            }
            vm.filterName = filterName;
            if ([filterName isEqualToString:self.selectFilterName]) {
                vm.selected = YES;
                hasSelect = YES;
                selectIndex = i;
            }else{
                vm.selected = NO;
            }

        }
        
        if (!hasSelect) {
            self.datas.firstObject.selected = YES;
        }
        
   
        self.label.text = self.nameArray[self.currentIndex];
        if (selectIndex > 0) {
            self.collectionView.alpha = 0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.collectionView  scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                [UIView animateWithDuration:0.1 animations:^{
                            self.collectionView.alpha = 1;
                }];
            });
        }else{
            self.currentIndex = selectIndex;
        }
        
        self.loaded = true;
    });


}

-(UIImage*)filterImage:(UIImage*)image name:(NSString*)name
{
    if (image && name && name.length > 0) {
        //1、先想办法弄到一个图像（CIImage*）
    //    UIImageView *theImageViewBack = [[UIImageView alloc]init];
    //     theImageViewBack.image = _ImageView;
        CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];

        return [self filterCIImage:inputImage name:name];
    }
   
    return image;
    
}

-(UIImage*)filterCIImage:(CIImage*)ciImage name:(NSString*)name
{
    if (ciImage) {
        //1、先想办法弄到一个图像（CIImage*）
    //    UIImageView *theImageViewBack = [[UIImageView alloc]init];
    //     theImageViewBack.image = _ImageView;
        CIImage *outputImage = ciImage;
        if (name && name.length > 0) {
            CIImage *inputImage = ciImage;
            //2、创建一个CIFilter*对象
            CIFilter* filter = [CIFilter filterWithName:name];
            //如果用下面这个方法初始化，3、4、5部都可以省略
            //CIFilter* filter = [CIFilter filterWithName:@"CICircularWrap" keysAndValues:@"inputImage",oldImg, nil];
            //3、设置默认参数
            [filter setDefaults];
            //4、设置要处理的图像
            [filter setValue:inputImage forKey:kCIInputImageKey];
    //        //5、得到处理后的图像
            outputImage  = filter.outputImage;
        }
        CGFloat scale = [UIScreen mainScreen].scale;
        
        // 调整大小，提高性能
        CIFilter *cropFilter = [CIFilter filterWithName:@"CIStretchCrop"];
        [cropFilter setDefaults];
        [cropFilter setValue:outputImage forKey:kCIInputImageKey];
        [cropFilter setValue:[CIVector vectorWithX:kZJSImageFilterSelectItemCellHeight*scale Y:kZJSImageFilterSelectItemCellHeight*scale] forKey:@"inputSize"];
        [cropFilter setValue:@1 forKey:@"inputCropAmount"];
        [cropFilter setValue:@0 forKey:@"inputCenterStretchAmount"];
        outputImage=cropFilter.outputImage;
//        UIImage *resultImg = [UIImage imageWithCIImage:outputImage];
        // 创建CIContex上下文对象。使用gpu
//        self.ciContext drawImage:<#(nonnull CIImage *)#> inRect:<#(CGRect)#> fromRect:<#(CGRect)#>
        CGImageRef cgImg = [self.ciContext createCGImage:outputImage fromRect:outputImage.extent];
        UIImage *resultImg = [UIImage imageWithCGImage:cgImg];
        CGImageRelease(cgImg);
        return resultImg;
//        return [self compressOriginalImage:resultImg withImageSize:CGSizeMake(20, 20)];
        //6、显示出来
    //     CIImage *outImage = filter.outputImage;
    //    [self addFilterLinkerWithImage:outImage];
    }
   
    return nil;
    
}

-(CIImage*)_filterCIImage:(CIImage*)ciImage name:(NSString*)name
{
    if (ciImage) {
        //1、先想办法弄到一个图像（CIImage*）
    //    UIImageView *theImageViewBack = [[UIImageView alloc]init];
    //     theImageViewBack.image = _ImageView;
        CIImage *outputImage = ciImage;
        if (name && name.length > 0) {
            CIImage *inputImage = ciImage;
            //2、创建一个CIFilter*对象
            CIFilter* filter = [CIFilter filterWithName:name];
            //如果用下面这个方法初始化，3、4、5部都可以省略
            //CIFilter* filter = [CIFilter filterWithName:@"CICircularWrap" keysAndValues:@"inputImage",oldImg, nil];
            //3、设置默认参数
            [filter setDefaults];
            //4、设置要处理的图像
            [filter setValue:inputImage forKey:kCIInputImageKey];
    //        //5、得到处理后的图像
            outputImage  = filter.outputImage;
        }
        return outputImage;
    }
   
    return nil;
    
}

- (UIImage *)compressOriginalImage:(UIImage *)originalImage withImageSize:(CGSize)size{
     // 开启图片上下文
     UIGraphicsBeginImageContext(size);
     // 将图片渲染到图片上下文
     [originalImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
     // 获取图片
     UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
     // 关闭图片上下文
     UIGraphicsEndImageContext();
     return newImage;
}

#pragma mark - getters and setters

-(void)setTargetIndex:(NSIndexPath *)targetIndex{
    _targetIndex = targetIndex;
//    DLog(@"targetIndex:%@",@(targetIndex.item) );
}

-(void)setCurrentIndex:(NSUInteger)currentIndex{
    if ( _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        
        NSString *filterName = self.datas[currentIndex].filterName;
        self.label.text = self.nameArray[self.currentIndex];
//        DLog(@"currentIndex:%@",@(currentIndex) );
        if ([self.delegate respondsToSelector:@selector(imageFilterSelectView:selectImage:filterName:)]) {
            [self.delegate imageFilterSelectView:self selectImage:self.datas[currentIndex].image filterName:filterName];
        }
    }
    
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.contentInset = UIEdgeInsetsZero;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        //        _collectionView.showsVerticalScrollIndicator = NO;
        //        _collectionView.layer.masksToBounds = NO;
        [_collectionView registerClass:[ZJSImageFilterSelectItemCell class] forCellWithReuseIdentifier:kZJSImageFilterSelectItemCellIdentify];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.layer.masksToBounds = NO;
        //        _collectionView.pagingEnabled = YES;
        //        _collectionView.pagingEnabled = YES;
        //        [self.collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    return _collectionView;
}

-(UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _layout;
}

-(UIView *)boundView{
    if (!_boundView) {
        _boundView = [[UIView alloc] init];
        _boundView.backgroundColor = [UIColor clearColor];
        _boundView.userInteractionEnabled = NO;
        _boundView.layer.cornerRadius = px(20);
        _boundView.layer.borderWidth = kZJSImageFilterSelectItemCellBoundBorderWidth;
        _boundView.layer.borderColor = [UIColor whiteColor].CGColor;
        _boundView.layer.masksToBounds = YES;
    }
    return _boundView;
}


-(UIView *)labelWrapper{
    if (!_labelWrapper) {
        _labelWrapper = [[UIView alloc] init];
        _labelWrapper.backgroundColor = [UIColor blackColor];
        _labelWrapper.layer.cornerRadius = px(8);
        _labelWrapper.layer.masksToBounds = YES;
        [_labelWrapper addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_labelWrapper).insets(UIEdgeInsetsMake(px(8), px(16), px(8), px(16)));
        }];
    }
    return _labelWrapper;
}

-(UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:px(27)];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

-(void)setImage:(UIImage *)image{
    _image = image;

    if (self.loaded) {
        for (int i = 0; i < self.nameArray.count; i ++) {
            ZJSImageFilterSelectItemCellViewModel *vm = self.datas[i];
            NSString *filterName = self.dict[self.nameArray[i]];
            vm.image = [self filterImage: self.image name:filterName];
        }
    }else{
        [self requestData];
    }
}

-(void)setCiImage:(CIImage *)ciImage{
    _ciImage = ciImage;
    if (self.loaded) {
        for (int i = 0; i < self.nameArray.count; i ++) {
            ZJSImageFilterSelectItemCellViewModel *vm = self.datas[i];
            NSString *filterName = self.dict[self.nameArray[i]];
            UIImage *image = [self filterCIImage:self.ciImage name:filterName];
            dispatch_async(dispatch_get_main_queue(), ^{
                vm.image = image;
            });
        }
    }else{
        [self requestData];
    }
}

// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIColorControls
- (NSArray *)nameArray {
    if (!_nameArray) {
        _nameArray = @[@"原片", @"怀旧",@"褪色",@"岁月",@"铬黄",@"冲印",@"色调",@"单色",@"黑白",];
    }
    return _nameArray;
}

- (NSDictionary *)dict {
    if (!_dict) {
        _dict = @{
            @"怀旧": @"CIPhotoEffectInstant",
            @"单色": @"CIPhotoEffectMono",
            @"黑白": @"CIPhotoEffectNoir",
            @"褪色": @"CIPhotoEffectFade",
            @"色调": @"CIPhotoEffectTonal",
            @"冲印": @"CIPhotoEffectProcess",
            @"岁月": @"CIPhotoEffectTransfer",
            @"铬黄": @"CIPhotoEffectChrome",
           
        };
    }
    return _dict;
}
@end
