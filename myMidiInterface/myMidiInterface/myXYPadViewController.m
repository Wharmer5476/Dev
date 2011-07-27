//
//  myXYPadViewController.m
//  myMidiInterface
//
//  Created by Wills Everyday on 21/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import "myXYPadViewController.h"
#import "XYTouch.h"

@implementation myXYPadViewController
@synthesize _xypad, _fingerText, _yFader, _xFader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage* anImage = [UIImage imageNamed:@"xypad.png"];
        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"XY Pad" image:anImage tag:1];
        self.tabBarItem = theItem;
        [anImage release];
        [theItem release];
    }
    return self;
}

- (void)dealloc
{
    [_yFader release];
    [_xFader release];
    [_fingerText release];
    [_xypad release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _yFader.transform = CGAffineTransformMakeRotation(-M_PI/2);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:_xypad];
    _fingerText.center = location;
    NSLog(@"I've been touched %f, %f", location.x, location.y);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:_xypad];

   NSLog(@"I've been cancelled %f, %f", location.x, location.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:_xypad];
    _fingerText.textColor = [UIColor whiteColor];
    NSLog(@"I've been ended %f, %f", location.x, location.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:_xypad];
    _fingerText.center = location;
    _fingerText.textColor = [UIColor redColor];
    NSLog(@"I've been moveed %f, %f", location.x, location.y);
}

@end
