## BayCarouselView

[![Build Status](https://travis-ci.org/shanbay/BayCarouselView.svg?branch=master)](https://travis-ci.org/shanbay/BayCarouselView) [![GitHub release](https://img.shields.io/github/release/shanbay/BayCarouselView.svg)](https://github.com/shanbay/BayCarouselView/releases) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

### A simple UITableView like carousel view.

![](image01.gif)

## Usage

```objective-c
#import "BayCarouselView.h"

BayCarouselView *view = [[BayCarouselView alloc] initWithFrame:self.view.frame];
[view registerClass:[BayCarouselTestItemView class]];
view.rowWidth = 300;
view.delegate = self;
view.dataSource = self;
view.clipsToBounds = NO;
view.pagingEnabled = YES;
[self.view addSubview:view];
[view scrollToIndex:12 animate:YES];
```

## Datasource

```objective-c
- (NSInteger)numberOfRowInCarouselView:(BayCarouselView *)carouselView {
    return 20;
}

- (BayCarouselItemView *)carouselView:(BayCarouselView *)carouselView viewForRowAtIndex:(NSInteger)index {
    BayCarouselTestItemView *view = [carouselView dequeueReusableView];
    CGRect frame = view.frame;
    frame.size = CGSizeMake(280, 527);
    view.frame = frame;
    return view;
}
```

## Delegate

```objective-c
// Display customization
- (void)carouselView:(BayCarouselView *)carouselView willDisplayView:(BayCarouselItemView *)view forRowAtIndex:(NSInteger)index;
- (void)carouselView:(BayCarouselView *)carouselView didEndDisplayView:(BayCarouselItemView *)view forRowAtIndex:(NSInteger)index;

- (void)carouselView:(BayCarouselView *)carouselView currentIndex:(NSInteger)index;

// TODO
- (void)carouselView:(BayCarouselView *)carouselView didSelectRowAtIndex:(NSInteger)index;
- (void)carouselView:(BayCarouselView *)carouselView didDeSelectRowAtIndex:(NSInteger)index;
```

## License

```
The MIT License (MIT)
Copyright (c) 2016 Shanbay.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

