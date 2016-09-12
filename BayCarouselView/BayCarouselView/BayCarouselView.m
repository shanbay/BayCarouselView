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
@property (nonatomic, strong) NSMutableArray *reusableViewArray;
@property (nonatomic, strong) NSMutableSet *reusableViewPool;
@property (nonatomic, strong) Class registerClass;
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
    self.reusableViewArray = [NSMutableArray array];
    self.reusableViewPool = [NSMutableSet set];
    self.numberOfRows = 0;
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (BayCarouselItemView *view in scrollView.subviews) {
        if ([view isKindOfClass:self.registerClass]) {
            if (CGRectGetMaxX(view.frame) < scrollView.contentOffset.x || CGRectGetMinX(view.frame) > scrollView.contentOffset.x + scrollView.frame.size.width) {
                [self queueReusableView:view];
                [view removeFromSuperview];
                if ([self.delegate respondsToSelector:@selector(carouselView:didEndDisplayView:forRowAtIndex:)]) {
                    [self.delegate carouselView:self didEndDisplayView:view forRowAtIndex:view.itemIndex];
                }
            }
        }
    }
    
    float maxX = scrollView.contentOffset.x + self.scrollView.frame.size.width;
    float minX = scrollView.contentOffset.x;
    
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

    if (CGRectGetMaxX(lastView.frame) <= maxX) {
        if (lastView.itemIndex + 1 < self.numberOfRows) {
            BayCarouselItemView *view = [self generateViewWithIndex:lastView.itemIndex + 1];
            [self.scrollView addSubview:view];
            lastView = view;
        }
    }
    
    if (CGRectGetMinX(firstView.frame) > minX) {
        if (firstView.itemIndex > 0) {
            BayCarouselItemView *view = [self generateViewWithIndex:firstView.itemIndex - 1];
            [self.scrollView addSubview:view];
            firstView = view;
        }
    }
}

#pragma mark - private

- (void)queueReusableView:(BayCarouselItemView *)view {
    [self.reusableViewPool addObject:view];
}

- (BayCarouselItemView *)generateViewWithIndex:(NSInteger)index {
    
    BayCarouselItemView *view = [self.dataSource carouselView:self viewForRowAtIndex:index];
    view.itemIndex = index;
    CGRect frame = view.frame;
    float padding = (self.rowWidth - view.frame.size.width) / 2;
    frame.origin.x = self.rowWidth * view.itemIndex + padding;
    view.frame = frame;
    CGPoint center = view.center;
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
    
    for (NSInteger i = 0; i < self.numberOfRows; i++) {
        BayCarouselItemView *view = [self generateViewWithIndex:i];
        [self.scrollView addSubview:view];
        
        if (CGRectGetMaxX(view.frame) > self.frame.size.width) {
            break;
        }
    }
}

- (void)scrollToIndex:(NSInteger)index animate:(BOOL)animate {
    [self.scrollView setContentOffset:CGPointMake(self.rowWidth * index, 0) animated:animate];
}

#pragma mark - set

- (void)setDelegate:(id<BayCarouselViewDelegate>)delegate {
    
    if (_delegate != delegate) {
        _delegate = delegate;
        if (_delegate && _dataSource) {
            
            [self setNeedsLayout];
        }
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
    frame.size.width = rowWidth;
    self.scrollView.frame = frame;
    
    CGPoint center = self.scrollView.center;
    center.x = self.center.x;
    self.scrollView.center = center;
}

#pragma mark - lazy load

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

@end