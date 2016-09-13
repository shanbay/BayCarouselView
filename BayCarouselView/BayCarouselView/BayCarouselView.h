//
//  BayCarouselView.h
//  BayCarouselView
//
//  Created by Jet Lee on 9/12/16.
//  Copyright © 2016 Shanbay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BayCarouselView;
@class BayCarouselItemView;

NS_ASSUME_NONNULL_BEGIN

@protocol BayCarouselViewDelegate <NSObject, UIScrollViewDelegate>

@optional
// Display customization
- (void)carouselView:(BayCarouselView *)carouselView willDisplayView:(UIView *)view forRowAtIndex:(NSInteger)index;
- (void)carouselView:(BayCarouselView *)carouselView didEndDisplayView:(UIView *)view forRowAtIndex:(NSInteger)index;

- (void)carouselView:(BayCarouselView *)carouselView didSelectRowAtIndex:(NSInteger)index;
- (void)carouselView:(BayCarouselView *)carouselView didDeSelectRowAtIndex:(NSInteger)index;

@end

@protocol BayCarouselViewDataSource <NSObject>

@required

- (NSInteger)numberOfRowInCarouselView:(BayCarouselView *)carouselView;
- (BayCarouselItemView *)carouselView:(BayCarouselView *)carouselView viewForRowAtIndex:(NSInteger)index;
@end


@interface BayCarouselView : UIView

@property (nonatomic, weak) __nullable id <BayCarouselViewDataSource> dataSource;
@property (nonatomic, weak) __nullable id <BayCarouselViewDelegate> delegate;
@property (nonatomic, assign) float rowWidth;
@property (nonatomic, assign) BOOL clipsToBounds;
@property (nonatomic, assign) BOOL pagingEnabled;

- (void)reloadData;
- (UIView *)dequeueReusableView;
- (void)registerClass:(nullable Class)viewClass;
- (void)scrollToIndex:(NSInteger)index animate:(BOOL)animate;
@end

NS_ASSUME_NONNULL_END
