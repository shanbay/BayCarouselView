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

@interface BayCarouselView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, strong) NSMutableSet *reusableViewPool;
@property (nonatomic, strong) Class registerClass;
@property (nonatomic, assign, getter=isLeftItemLoaded) BOOL leftItemLoaded;
@property (nonatomic, assign, getter=isRightItemLoaded) BOOL rightItemLoaded;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) float defaultItemHeight;
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
    self.reusableViewPool = [NSMutableSet set];
    self.numberOfRows = 0;
    for (BayCarouselItemView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    
    CGRect frame = self.scrollView.frame;
    frame.size.width = self.rowWidth;
    self.scrollView.frame = frame;
    
    CGPoint center = self.scrollView.center;
    center.x = self.center.x;
    self.scrollView.center = center;
    
    for (BayCarouselItemView *view in self.scrollView.subviews) {
        if (view.itemIndex != self.currentIndex) {
            CGRect frame = view.frame;
            frame.size.height = self.defaultItemHeight * 0.8;
            view.frame = frame;
        }
        CGPoint center = view.center;
        center.x = (view.itemIndex + 0.5) * self.rowWidth;
        center.y = self.center.y;
        view.center = center;
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float padding = (self.frame.size.width - self.rowWidth) / 2;
    
    float maxX = scrollView.contentOffset.x + self.scrollView.frame.size.width;
    float minX = scrollView.contentOffset.x;
    
    for (BayCarouselItemView *view in scrollView.subviews) {
        if ([view isKindOfClass:self.registerClass]) {
            if (CGRectGetMaxX(view.frame) < scrollView.contentOffset.x - padding || CGRectGetMinX(view.frame) > scrollView.contentOffset.x + scrollView.frame.size.width + padding) {
                [self queueReusableView:view];
#ifdef DEBUG
                //                NSLog(@"remove %ld", view.itemIndex);
#endif
                [view removeFromSuperview];
                if ([self.delegate respondsToSelector:@selector(carouselView:didEndDisplayView:forRowAtIndex:)]) {
                    [self.delegate carouselView:self didEndDisplayView:view forRowAtIndex:view.itemIndex];
                }
            }
            
            CGFloat viewCenterX = view.center.x;
            CGFloat centerX = scrollView.contentOffset.x + self.rowWidth / 2;
            CGFloat scale = (centerX - viewCenterX) / self.rowWidth;
            if (scale < 0) {
                scale = scale * -1;
            }
            CGRect frame = view.frame;
            frame.size.height = self.defaultItemHeight - (self.defaultItemHeight * 0.2) * scale;
            view.frame = frame;
            CGPoint center = view.center;
            center.x = (view.itemIndex + 0.5) * self.rowWidth;
            center.y = self.center.y;
            view.center = center;
        }
    }
    
    NSArray *subviewsArray = [self.scrollView.subviews sortedArrayUsingComparator:^NSComparisonResult(BayCarouselItemView *obj1, BayCarouselItemView *obj2) {
        
        return [[NSNumber numberWithFloat:obj1.frame.origin.x] compare:[NSNumber numberWithFloat:obj2.frame.origin.x]];
    }];
    
    BayCarouselItemView *firstView;
    for (NSInteger i = 0; i < subviewsArray.count; i++) {
        if ([subviewsArray[i] isKindOfClass:self.registerClass]) {
            firstView = subviewsArray[i];
            break;
        }
    }
    
    BayCarouselItemView *lastView;
    for (NSInteger j = subviewsArray.count - 1; j >= 0; j--) {
        if ([subviewsArray[j] isKindOfClass:self.registerClass]) {
            lastView = subviewsArray[j];
            break;
        }
    }
    
    
    if (lastView && CGRectGetMaxX(lastView.frame) < maxX && !self.isRightItemLoaded) {
        
        self.currentIndex = lastView.itemIndex;
        self.rightItemLoaded = YES;
        self.leftItemLoaded = NO;
        if (lastView.itemIndex + 1 < self.numberOfRows) {
            BayCarouselItemView *view = [self generateViewWithIndex:lastView.itemIndex + 1];
            [self.scrollView addSubview:view];
        }
    }
    
    if (firstView && CGRectGetMinX(firstView.frame) > minX && !self.isLeftItemLoaded) {
        
        self.currentIndex = firstView.itemIndex;
        self.leftItemLoaded = YES;
        self.rightItemLoaded = NO;
        if (firstView.itemIndex > 0) {
            BayCarouselItemView *view = [self generateViewWithIndex:firstView.itemIndex - 1];
            [self.scrollView addSubview:view];
        }
    }
    
    if (!firstView && !lastView) {
        self.currentIndex = scrollView.contentOffset.x / self.rowWidth;
        BayCarouselItemView *view = [self generateViewWithIndex:self.currentIndex];
        [self.scrollView addSubview:view];
        [self scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    self.leftItemLoaded = NO;
    self.rightItemLoaded = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(carouselView:currentIndex:)]) {
        [self.delegate carouselView:self currentIndex:self.currentIndex];
    }
}

#pragma mark - private

- (void)queueReusableView:(BayCarouselItemView *)view {
    [self.reusableViewPool addObject:view];
}

- (BayCarouselItemView *)generateViewWithIndex:(NSInteger)index {
#ifdef DEBUG
    //    NSLog(@"generateViewWithIndex %ld", index);
#endif
    BayCarouselItemView *view = [self.dataSource carouselView:self viewForRowAtIndex:index];
    view.itemIndex = index;
    self.defaultItemHeight = view.frame.size.height;
    if (index != self.currentIndex) {
        CGRect frame = view.frame;
        frame.size.height = self.defaultItemHeight * 0.8;
        view.frame = frame;
    }
    CGPoint center = view.center;
    center.x = (view.itemIndex + 0.5) * self.rowWidth;
    center.y = self.center.y;
    view.center = center;
    
    if ([self.delegate respondsToSelector:@selector(carouselView:willDisplayView:forRowAtIndex:)]) {
        [self.delegate carouselView:self willDisplayView:view forRowAtIndex:view.itemIndex];
    }
    return view;
}

#pragma mark - public

- (BayCarouselItemView *)dequeueReusableView {
    if (self.reusableViewPool.count > 0) {
        BayCarouselItemView *view = [self.reusableViewPool anyObject];
        [self.reusableViewPool removeObject:view];
        return view;
    } else {
        return [[self.registerClass alloc] init];
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
    
    self.currentIndex = 0;
    BayCarouselItemView *view = [self generateViewWithIndex:0];
    [self.scrollView addSubview:view];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)scrollToIndex:(NSInteger)index animate:(BOOL)animate {
    self.currentIndex = index;
    [self.scrollView setContentOffset:CGPointMake(self.rowWidth * index, 0) animated:animate];
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

- (void)setRowWidth:(float)rowWidth {
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
