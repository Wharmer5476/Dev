//
//  RoundedUITableView.m
//  RoundedTableView
//
//  Created by Jeremy Collins on 1/7/10.
//  Copyright 2010 Beetlebug Software, LLC. All rights reserved.
//

#import "RoundedUIViewMask.h"
#import <QuartzCore/QuartzCore.h>

#define kCornerRadius 6.f

@implementation RoundedUIViewMask


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, kCornerRadius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, kCornerRadius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, kCornerRadius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, kCornerRadius);
    CGContextClosePath(context);
    CGContextFillPath(context);
}


- (void)dealloc {
    [super dealloc];
}


@end


/*
@implementation RoundedUIView


- (void)setupView {
    mask = [[RoundedUIViewMask alloc] initWithFrame:CGRectZero]; 
    self.layer.mask = mask.layer;
    self.layer.cornerRadius = kCornerRadius;   
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
	[self setupView];
    }

    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
	[self setupView];
    }
    
    return self;
}

- (void)dealloc {
    [mask release];
    [super dealloc];
}


@end
 */
