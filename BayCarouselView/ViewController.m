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
    view.backgroundColor = [UIColor redColor];
    view.delegate = self;
    view.dataSource = self;
    view.clipsToBounds = NO;
    view.pagingEnabled = YES;
    [self.view addSubview:view];
}
#pragma mark - BayCarouselViewDelegate

- (void)carouselView:(BayCarouselView *)carouselView willDisplayView:(UIView *)view forRowAtIndex:(NSInteger)index {
    NSLog(@"willDisplayView %ld", index);
}

- (void)carouselView:(BayCarouselView *)carouselView didEndDisplayView:(UIView *)view forRowAtIndex:(NSInteger)index {
    NSLog(@"didEndDisplayView %ld", index);
}
#pragma mark - BayCarouselViewDataSource

- (NSInteger)numberOfRowInCarouselView:(BayCarouselView *)carouselView {
    return 20;
}

- (UIView *)carouselView:(BayCarouselView *)carouselView viewForRowAtIndex:(NSInteger)index {
    UIView *view = [carouselView dequeueReusableView];
    CGRect frame = view.frame;
    frame.size = CGSizeMake(280, 527);
    view.frame = frame;
    
    view.backgroundColor = [UIColor yellowColor];
    return view;
}

@end
