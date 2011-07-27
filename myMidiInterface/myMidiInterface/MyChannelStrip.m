//
//  MyChannelStrip.m
//  myMidiInterface
//
//  Created by Wills Everyday on 23/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import "MyChannelStrip.h"


@implementation MyChannelStrip
@synthesize sendA, sendB, sendAValLabel, sendBValLabel, pan, panValLabel, fader, faderValLabel, muteButton, soloButton, recordButton, channelLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [sendA release];
    [sendB release];
    [sendAValLabel release];
    [sendBValLabel release];
    [pan release];
    [panValLabel release];
    [fader release];
    [faderValLabel release];
    [muteButton release];
    [soloButton release];
    [recordButton release];
    [channelLabel release];
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
    // Do any additional setup after loading the view from its nib
    fader.transform = CGAffineTransformMakeRotation(-M_PI/2);
    fader.maximumValue = 127;
    fader.minimumValue = 0;
    UIImage* anImage = [UIImage imageNamed:@"faderThumb.png"];
    [fader setThumbImage:anImage forState:UIControlStateNormal];
    [anImage release];
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
