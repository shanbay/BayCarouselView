//
//  ViewController.m
//  BayCarouselView
//
//  Created by Jet Lee on 9/12/16.
//  Copyright © 2016 Shanbay. All rights reserved.
//

#import "ViewController.h"
#import "BayCarouselView.h"
#import "BayCarouselTestItemView.h"

@interface ViewController () <BayCarouselViewDelegate, BayCarouselViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BayCarouselView *view = [[BayCarouselView alloc] initWithFrame:self.view.frame];
    [view registerClass:[BayCarouselTestItemView class]];
    view.rowWidth = 300;
    view.backgroundColor = HEXCOLOR(0xfdfdfd);
    view.delegate = self;
    view.dataSource = self;
    view.clipsToBounds = NO;
    view.pagingEnabled = YES;
    [self.view addSubview:view];
    [view scrollToIndex:12 animate:YES];
}
#pragma mark - BayCarouselViewDelegate

- (void)carouselView:(BayCarouselView *)carouselView willDisplayView:(BayCarouselItemView *)view forRowAtIndex:(NSInteger)index {
#ifdef DEBUG
//    NSLog(@"willDisplayView %ld", index);
#endif
}

- (void)carouselView:(BayCarouselView *)carouselView didEndDisplayView:(BayCarouselItemView *)view forRowAtIndex:(NSInteger)index {
#ifdef DEBUG
//    NSLog(@"didEndDisplayView %ld", index);
#endif
}
#pragma mark - BayCarouselViewDataSource

- (NSInteger)numberOfRowInCarouselView:(BayCarouselView *)carouselView {
    return 20;
}

- (BayCarouselItemView *)carouselView:(BayCarouselView *)carouselView viewForRowAtIndex:(NSInteger)index {
    BayCarouselTestItemView *view = [carouselView dequeueReusableView];
    CGRect frame = view.frame;
    frame.size = CGSizeMake(280, 527);
    view.frame = frame;
    
    view.text = [NSString stringWithFormat:@"当前 index: %ld", index];
    view.backgroundColor = HEXCOLOR(0x209e85);
    return view;
}

@end
