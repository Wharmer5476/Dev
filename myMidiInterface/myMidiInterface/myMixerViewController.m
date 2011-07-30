//
//  myMixerViewController.m
//  myMidiInterface
//
//  Created by Wills Everyday on 21/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import "myMixerViewController.h"
#import "MyChannelStrip.h"

@implementation myMixerViewController
@synthesize mixerPanel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage* anImage = [UIImage imageNamed:@"mixer.png"];
        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"Mixer" image:anImage tag:0];
        self.tabBarItem = theItem;
        [anImage release];
        [theItem release];
    }
    return self;
}

- (void)dealloc
{
    [mixerPanel release];
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
    mixerPanel.contentSize = CGSizeMake(0, 0);
    //CGFloat _xPoint = 0;
    MyChannelStrip *channel = [[MyChannelStrip alloc] initWithNibName:@"MyChannelStrip" bundle:nil];
    
    UIImage* anImage = [UIImage imageNamed:@"mixingDeskBackground.png"];
    channel.view.backgroundColor = [UIColor colorWithPatternImage:anImage];
    [mixerPanel addSubview:channel.view];
    [channel release];
    [anImage release];

    /*
    for (int i = 0; i < 9; i++) {
        MyChannelStrip *channel = [[MyChannelStrip alloc] initWithNibName:@"MyChannelStrip" bundle:nil];
        
        channel.view.frame = CGRectMake(_xPoint, 0, CGRectGetWidth(channel.view.frame), CGRectGetHeight(channel.view.frame));
        [mixerPanel addSubview:channel.view];
        channel.channelLabel.text = [NSString stringWithFormat:@"Channel %i", i];
        [channel release];
        _xPoint = _xPoint + (135);
        mixerPanel.contentSize = CGSizeMake(_xPoint, 0);
    }
    */
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

@end
