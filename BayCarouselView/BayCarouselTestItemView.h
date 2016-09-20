//
//  BayCarouselTestItemView.h
//  BayCarouselView
//
//  Created by Jet Lee on 9/12/16.
//  Copyright © 2016 Shanbay. All rights reserved.
//

#import "BayCarouselItemView.h"

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]

@interface BayCarouselTestItemView : BayCarouselItemView

@property (nonatomic, copy) NSString *text;
@end
