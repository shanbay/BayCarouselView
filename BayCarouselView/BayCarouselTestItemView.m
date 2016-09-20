//
//  BayCarouselTestItemView.m
//  BayCarouselView
//
//  Created by Jet Lee on 9/12/16.
//  Copyright © 2016 Shanbay. All rights reserved.
//

#import "BayCarouselTestItemView.h"

@interface BayCarouselTestItemView()

@property (nonatomic, strong) UILabel *label;
@end

@implementation BayCarouselTestItemView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

#pragma mark - setter

- (void)setText:(NSString *)text {
    _text = text;
    self.label.text = self.text;
}

#pragma mark - Lazy getter

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:20];
        _label.textColor = [UIColor grayColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}
@end
