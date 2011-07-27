//
//  MyChannelStrip.h
//  myMidiInterface
//
//  Created by Wills Everyday on 23/07/2011.
//  Copyright 2011 Cardiff Uni. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyChannelStrip : UIViewController {
    UILabel *channelLabel;
    CGFloat *width;
    CGFloat *height;
}
@property (nonatomic, retain) IBOutlet UIView *sendA;
@property (nonatomic, retain) IBOutlet UIView *sendB;
@property (nonatomic, retain) IBOutlet UILabel *sendAValLabel;
@property (nonatomic, retain) IBOutlet UILabel *sendBValLabel;
@property (nonatomic, retain) IBOutlet UIView *pan;
@property (nonatomic, retain) IBOutlet UILabel *panValLabel;
@property (nonatomic, retain) IBOutlet UISlider *fader;
@property (nonatomic, retain) IBOutlet UILabel *faderValLabel;
@property (nonatomic, retain) IBOutlet UIButton *muteButton;
@property (nonatomic, retain) IBOutlet UIButton *soloButton;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UILabel *channelLabel;

@end
