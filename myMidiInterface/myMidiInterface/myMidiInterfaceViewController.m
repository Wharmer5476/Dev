//
//  myMidiInterfaceViewController.m
//  myMidiInterface
//
//  Created by Wills Everyday on 18/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import "myMidiInterfaceViewController.h"
#import "myMixerViewController.h"
#import "myXYPadViewController.h"
#import "myFaceTrackerViewController.h"

@implementation myMidiInterfaceViewController
@synthesize transportControl = _transportControl;

- (void)dealloc
{
    [tabBarController release];
    [_transportControl release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the drawer view
    // drawerController = [[DrawerViewController alloc] initWithNibName:@"DrawerViewController" bundle:nil];
    
    // Create the Tab bar
    tabBarController = [[UITabBarController alloc] init];
    
    myMixerViewController* vc1 = [[myMixerViewController alloc] initWithNibName:@"myMixerViewController" bundle:nil];
    myXYPadViewController* vc2 = [[myXYPadViewController alloc] initWithNibName:@"myXYPadViewController" bundle:nil];
    myFaceTrackerViewController* vc3 = [[myFaceTrackerViewController alloc] initWithNibName:@"myFaceTrackerViewController" bundle:nil];
    
    NSArray* controllers = [NSArray arrayWithObjects:vc1, vc2, vc3, nil];
    [vc1 release]; [vc2 release]; [vc3 release];
    tabBarController.viewControllers = controllers;
    [controllers release];
    tabBarController.view.frame = self.view.bounds;
    // tabBarController.delegate = drawerController;
    
    // Add the tab bar controller's current view as a subview of the current view
    [self.view addSubview:tabBarController.view];
    
    // Create a trasport control toolbar
    [self.view addSubview:_transportControl];
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

#pragma mark - custom methods


@end
