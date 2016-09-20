//
//  BayCarouselView.m
//  BayCarouselView
//
//  Created by Jet Lee on 9/12/16.
//  Copyright © 2016 Shanbay. All rights reserved.
//

#import "BayCarouselView.h"
#import "BayCarouselItemView.h"

static NSString * const BayCarouselViewIdentifier = @"BayCarouselViewIdentifier";
static CGFloat const BayCarouselDefaultScaleX = 0.9;
static CGFloat const BayCarouselDefaultScaleY = 0.8;

@interface BayCarouselView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, strong) NSMutableSet *reusableViewPool;
@property (nonatomic, strong) Class registerClass;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGFloat cardInset;
@end

@implementation BayCarouselView
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        [self addSubview:self.scrollView];
        self.rowWidth = 320;
    }
    return self;
}

- (void)commonInit {
    for (BayCarouselItemView *view in self.scrollView.subviews) {
        view.hidden = YES;
    }
    self.reusableViewPool = [NSMutableSet set];
    self.numberOfRows = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    
    CGRect frame = self.scrollView.frame;
    frame.size.width = self.rowWidth;
    self.scrollView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(self.rowWidth * self.numberOfRows, self.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.rowWidth * self.currentIndex, 0);
    
    CGPoint center = self.scrollView.center;
    center.x = self.center.x;
    self.scrollView.center = center;
    
    for (BayCarouselItemView *view in self.scrollView.subviews) {
        CGPoint center = view.center;
        center.x = (view.itemIndex + 0.5) * self.rowWidth;
        center.y = self.center.y;
        view.center = center;
    }
    [self scrollViewDidScroll:self.scrollView];
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat padding = (self.frame.size.width - self.rowWidth) / 2;
    
    CGFloat maxX = scrollView.contentOffset.x + self.scrollView.frame.size.width;
    CGFloat minX = scrollView.contentOffset.x;
    
    for (BayCarouselItemView *view in scrollView.subviews) {
        if ([view isKindOfClass:self.registerClass]) {
            if (CGRectGetMaxX(view.frame) < minX - padding * 2 || CGRectGetMinX(view.frame) > maxX + padding * 2) {
                
                if (!view.hidden) {
                    [self queueReusableView:view];
#ifdef DEBUG
                    //                    NSLog(@"remove %ld", view.itemIndex);
#endif
                    view.hidden = YES;
                    if ([self.delegate respondsToSelector:@selector(carouselView:didEndDisplayView:forRowAtIndex:)]) {
                        [self.delegate carouselView:self didEndDisplayView:view forRowAtIndex:view.itemIndex];
                    }
                }
            }
            
            CGFloat viewCenterX = view.center.x;
            CGFloat centerX = scrollView.contentOffset.x + self.rowWidth / 2;
            CGFloat scale = (centerX - viewCenterX) / self.rowWidth;
            if (scale < 0) {
                scale = scale * -1;
            }
            CGFloat scaleX = 1 - (1 - BayCarouselDefaultScaleX) * scale;
            CGFloat scaleY = 1 - (1 - BayCarouselDefaultScaleY) * scale;
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY);
            CGPoint center = view.center;
            center.x = (view.itemIndex + 0.5) * self.rowWidth;
            center.y = self.center.y;
            view.center = center;
            [view setNeedsLayout];
        }
    }
    
    NSArray *subviewsArray = [self.scrollView.subviews sortedArrayUsingComparator:^NSComparisonResult(BayCarouselItemView *obj1, BayCarouselItemView *obj2) {
        
        return [[NSNumber numberWithFloat:obj1.frame.origin.x] compare:[NSNumber numberWithFloat:obj2.frame.origin.x]];
    }];
    
    BayCarouselItemView *firstView;
    for (NSInteger i = 0; i < subviewsArray.count; i++) {
        if ([subviewsArray[i] isKindOfClass:self.registerClass]) {
            if (!((BayCarouselItemView *)(subviewsArray[i])).hidden) {
                firstView = subviewsArray[i];
                break;
            }
        }
    }
    
    BayCarouselItemView *lastView;
    for (NSInteger j = subviewsArray.count - 1; j >= 0; j--) {
        if ([subviewsArray[j] isKindOfClass:self.registerClass]) {
            if (!((BayCarouselItemView *)(subviewsArray[j])).hidden) {
                lastView = subviewsArray[j];
                break;
            }
        }
    }
    
    // 如果符合条件就生成右边的 view
    if (lastView && CGRectGetMaxX(lastView.frame) < maxX + padding - self.cardInset) {
        
        self.currentIndex = lastView.itemIndex;
        if (lastView.itemIndex + 1 < self.numberOfRows) {
            [self generateViewWithIndex:lastView.itemIndex + 1];
        }
    }
    
    // 如果符合条件就生成左边的 view
    if (firstView && CGRectGetMinX(firstView.frame) > minX - padding + self.cardInset) {
        
        self.currentIndex = firstView.itemIndex;
        if (firstView.itemIndex > 0) {
            [self generateViewWithIndex:firstView.itemIndex - 1];
        }
    }
    
    // 如果一个 subview 都没有，执行类似 reloadData 的操作
    if (!firstView && !lastView) {
        self.currentIndex = scrollView.contentOffset.x / self.rowWidth;
        [self renderCurrentView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([self.delegate respondsToSelector:@selector(carouselView:currentIndex:)]) {
        [self.delegate carouselView:self currentIndex:self.currentIndex];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // setContentOffset 之后，并且跟上次不一样的才会调用
    [self scrollViewDidScroll:self.scrollView];
}

#pragma mark - private

- (void)renderCurrentView {
    [self generateViewWithIndex:self.currentIndex];
}

- (void)queueReusableView:(BayCarouselItemView *)view {
    [self.reusableViewPool addObject:view];
}

- (BayCarouselItemView *)generateViewWithIndex:(NSInteger)index {
    if (self.numberOfRows <= index) {
        return nil;
    }
#ifdef DEBUG
    //    NSLog(@"generateViewWithIndex %ld", index);
#endif
    BayCarouselItemView *view = [self.dataSource carouselView:self viewForRowAtIndex:index];
    view.itemIndex = index;
    self.cardInset = (self.rowWidth - CGRectGetWidth(view.frame)) / 2;
    
    if (index != self.currentIndex) {
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, BayCarouselDefaultScaleX, BayCarouselDefaultScaleY);
    }
    CGPoint center = view.center;
    center.x = (view.itemIndex + 0.5) * self.rowWidth;
    center.y = self.center.y;
    view.center = center;
    
    if ([self.delegate respondsToSelector:@selector(carouselView:willDisplayView:forRowAtIndex:)]) {
        [self.delegate carouselView:self willDisplayView:view forRowAtIndex:view.itemIndex];
    }
    view.hidden = NO;
    return view;
}

#pragma mark - public

- (void)resetData {
    
    for (BayCarouselItemView *view in self.scrollView.subviews) {
        view.hidden = YES;
    }
}

- (BayCarouselItemView *)dequeueReusableView {
    if (self.reusableViewPool.count > 0) {
        BayCarouselItemView *view = [self.reusableViewPool anyObject];
        view.transform = CGAffineTransformIdentity;
        [self.reusableViewPool removeObject:view];
        return view;
    } else {
        BayCarouselItemView *view = [[self.registerClass alloc] init];
        [self.scrollView addSubview:view];
        return view;
    }
}

- (void)registerClass:(Class)viewClass {
    self.registerClass = viewClass;
}

- (void)reloadData {
    [self commonInit];
    
    if (!self.dataSource) {
        return;
    }
    if ([self.dataSource respondsToSelector:@selector(numberOfRowInCarouselView:)]) {
        
        self.numberOfRows = [self.dataSource numberOfRowInCarouselView:self];
    }
    self.scrollView.contentSize = CGSizeMake(self.rowWidth * self.numberOfRows, self.frame.size.height);
    if (self.scrollView.subviews == 0) {
        // 整个的思路是在屏幕上先加上一个肯定存在的 view，再在 scrollViewDidScroll 里面决定哪些需要删去，哪些需要生成
        [self renderCurrentView];
    }
}

- (void)scrollToIndex:(NSInteger)index animate:(BOOL)animate {
    self.currentIndex = index;
    [self renderCurrentView];
    
    if (self.rowWidth * index == self.scrollView.contentOffset.x) {
        [self.scrollView setContentOffset:CGPointMake(self.rowWidth * index + 1, 0) animated:animate];
    } else {
        [self.scrollView setContentOffset:CGPointMake(self.rowWidth * index, 0) animated:animate];
    }
}

#pragma mark - set

- (void)setDelegate:(id<BayCarouselViewDelegate>)delegate {
    
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)setDataSource:(id<BayCarouselViewDataSource>)dataSource {
    
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        if (_dataSource) {
            [self reloadData];
        }
    }
}

- (void)setRowWidth:(CGFloat)rowWidth {
    _rowWidth = rowWidth;
    CGRect frame = self.scrollView.frame;
    CGPoint center = self.scrollView.center;
    center.x = self.center.x;
    self.scrollView.center = center;
    frame.size.width = rowWidth;
    self.scrollView.frame = frame;
    
    [self reloadData];
}

- (void)setClipsToBounds:(BOOL)clipsToBounds {
    _clipsToBounds = clipsToBounds;
    self.scrollView.clipsToBounds = clipsToBounds;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    _pagingEnabled = pagingEnabled;
    self.scrollView.pagingEnabled = pagingEnabled;
}

#pragma mark - lazy load

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

@end
