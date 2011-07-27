//
//  XYTouch.m
//  myMidiInterface
//
//  Created by Wills Everyday on 23/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import "XYTouch.h"
#import <QuartzCore/QuartzCore.h>

@implementation XYTouch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.multipleTouchEnabled = NO;
        
    } 
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
}

- (void)dealloc
{
    [_fingertext release];
    [super dealloc];
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
    NSLog(@"I've been touched %f, %f", location.x, location.y);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
    
    NSLog(@"I've been cancelled %f, %f", location.x, location.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
    NSLog(@"I've been ended %f, %f", location.x, location.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
    NSLog(@"I've been moveed %f, %f", location.x, location.y);
}
*/

@end
