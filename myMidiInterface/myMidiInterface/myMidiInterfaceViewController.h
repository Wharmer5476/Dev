//
//  myMidiInterfaceViewController.h
//  myMidiInterface
//
//  Created by Wills Everyday on 18/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawerViewController.h"

@interface myMidiInterfaceViewController : UIViewController {
    UITabBarController *tabBarController;
    DrawerViewController *drawerController;
}
@property (nonatomic, retain) IBOutlet UIView *transportControl;

@end
