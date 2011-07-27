//
//  myFaceTrackerViewController.m
//  myMidiInterface
//
//  Created by Wills Everyday on 21/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import "myFaceTrackerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

@interface myFaceTrackerViewController()
-(AVCaptureDevice *)frontFacingCameraIfAvalailable;

@end

@implementation myFaceTrackerViewController
@synthesize vImagePreview=_vImagePreview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage* anImage = [UIImage imageNamed:@"facetracker.png"];
        UITabBarItem* theItem = [[UITabBarItem alloc] initWithTitle:@"FaceTracker" image:anImage tag:1];
        self.tabBarItem = theItem;
        [anImage release];
        [theItem release];
    }
    return self;
}

- (void)dealloc
{
    [_vImagePreview release];
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
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetMedium;
    
	CALayer *viewLayer = self.vImagePreview.layer;
	NSLog(@"viewLayer = %@", viewLayer);
    
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
	captureVideoPreviewLayer.frame = self.vImagePreview.bounds;
	[self.vImagePreview.layer addSublayer:captureVideoPreviewLayer];
    
	AVCaptureDevice *device = [self frontFacingCameraIfAvalailable];
    
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
	[session addInput:input];
    
	[session startRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
    
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

-(AVCaptureDevice *)frontFacingCameraIfAvalailable {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
    
    // couldn't find camera on the front, so just get the default video device.
    if (! captureDevice) {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

@end
