//
//  myMidiInterfaceAppDelegate.h
//  myMidiInterface
//
//  Created by Wills Everyday on 18/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import <UIKit/UIKit.h>

@class myMidiInterfaceViewController;

@interface myMidiInterfaceAppDelegate : NSObject <UIApplicationDelegate> {
    myMidiInterfaceViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet myMidiInterfaceViewController *viewController;

@end
