//
//  ACI_PageControl.m
//  bundespresseamt
//
//  Created by Ralph-Gordon Paul on 20.03.14.
//  Copyright (c) 2014 AppCom Interactive GmbH. All rights reserved.
//

#import "ACI_PageControl.h"

@interface ACI_PageControl ()

@property (nonatomic) NSRange visibleDotsRange;
@property (nonatomic, strong,) UIPageControl *pageControl;

@property (nonatomic) NSInteger maximumNumberOfVisiblePages;
@property (nonatomic) NSRange rangeOfVisiblePages;

@end
@implementation ACI_PageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizesSubviews = NO;
    self.clipsToBounds = YES;
    _pageControl = [[UIPageControl alloc] initWithFrame:self.bounds];
    [self addSubview:_pageControl];
    _rangeOfVisiblePages = NSMakeRange(0, 0);
    [self calculateMaximumNumberOfVisiblePages];
}

// calculate maximum number of possible visible dots
- (void)calculateMaximumNumberOfVisiblePages
{
    _maximumNumberOfVisiblePages = 0;
    CGSize reqSize = [self.pageControl sizeForNumberOfPages:0];
    while (reqSize.width <= self.pageControl.frame.size.width) {
        _maximumNumberOfVisiblePages++;
        reqSize = [self.pageControl sizeForNumberOfPages:_maximumNumberOfVisiblePages + 1];
    }
}

- (void)calculateRangeOfVisiblePages
{
    if (self.currentPage <= self.rangeOfVisiblePages.location || self.currentPage >= self.rangeOfVisiblePages.location + self.rangeOfVisiblePages.length - 1) {
        NSInteger index = 0;
        
        while ((self.currentPage >= index + self.maximumNumberOfVisiblePages - 1) /*|| (self.currentPage)*/) {
            index += self.maximumNumberOfVisiblePages / 2;
        }
        self.rangeOfVisiblePages = NSMakeRange(index, self.maximumNumberOfVisiblePages);
    }
}

- (void)positionPageControlAnimated:(BOOL)animated
{
    CGFloat posX = 0;
    
    if (self.rangeOfVisiblePages.location > 0) {
        posX = self.rangeOfVisiblePages.location * 16;
        posX = -posX;
    }
    
    void (^animationBlock)() = ^() {
        self.pageControl.frame = (CGRect) {
            .origin.x = posX,
            .origin.y = self.pageControl.frame.origin.y,
            .size = self.pageControl.frame.size
        };
    };
    
    if (animated) [UIView animateWithDuration:0.25f animations:animationBlock];
    else animationBlock();
}

#pragma mark - Getter / Setter

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (self.currentPage != currentPage) {
        self.pageControl.currentPage = currentPage;
        [self calculateRangeOfVisiblePages];
        [self positionPageControlAnimated:YES];
    }
}

- (NSInteger)currentPage
{
    return self.pageControl.currentPage;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    self.pageControl.numberOfPages = numberOfPages;
    
    // if we just fit inside our boumds -> just set the frame to bounds to center the dots
    if (self.maximumNumberOfVisiblePages < numberOfPages) {
        self.pageControl.frame = (CGRect) {
            .origin.x = 0,
            .origin.y = 0,
            .size = [self.pageControl sizeForNumberOfPages:numberOfPages]
        };
    } else {
        self.pageControl.frame = self.bounds;
    }
    
    [self calculateRangeOfVisiblePages];
}

- (NSInteger)numberOfPages
{
    return self.pageControl.numberOfPages;
}

@end