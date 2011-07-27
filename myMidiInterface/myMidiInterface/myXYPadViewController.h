//
//  myXYPadViewController.h
//  myMidiInterface
//
//  Created by Wills Everyday on 21/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XYTouch;

@interface myXYPadViewController : UIViewController {
    XYTouch *_xypad;
    UILabel *_fingerText;
    UISlider *_yFader;
    UISlider *_xFader;
}
@property (nonatomic, retain) IBOutlet XYTouch *_xypad;
@property (nonatomic, retain) IBOutlet UILabel *_fingerText;
@property (nonatomic, retain) IBOutlet UISlider *_yFader;
@property (nonatomic, retain) IBOutlet UISlider *_xFader;

@end
