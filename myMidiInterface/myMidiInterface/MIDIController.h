//
//  MIDIController.h
//  Molten
//
//  Created by Peter Johnson on 02/12/10.
//  Copyright 2010 One Red Dog Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CoreMIDI/MIDINetworkSession.h>

@interface MIDIController : UIViewController <NSNetServiceBrowserDelegate, NSNetServiceDelegate, UITableViewDelegate, UITableViewDataSource>
{
    // MIDI Port assignment switches
    NSMutableArray* portNames;
    NSMutableArray* inPorts;
    NSMutableArray* inClocks;
    NSMutableArray* outPorts;
    NSMutableArray* outClocks;
    
    // Bonjour sevice browser
    BOOL isConnected;
    NSNetServiceBrowser* browser;
    NSNetService* connectedService;
    NSMutableArray* services;
    
    UITableView* mTableView;
}

@property (readwrite, retain) NSMutableArray *portNames;
@property (readwrite, retain) NSMutableArray *inPorts;
@property (readwrite, retain) NSMutableArray *inClocks;
@property (readwrite, retain) NSMutableArray *outPorts;
@property (readwrite, retain) NSMutableArray *outClocks;

@property (readwrite, assign) BOOL isConnected;
@property (readwrite, retain) NSNetServiceBrowser* browser;
@property (readwrite, retain) NSNetService* connectedService;
@property (readwrite, retain) NSMutableArray* services;

- (void)connectionsTable;

- (IBAction)switchedLocal:(id)sender;
- (IBAction)switchedExtIn:(id)sender;

- (IBAction)switchedDriver:(id)sender;
- (IBAction)switchedNetAccept:(id)sender;

- (IBAction)switchedInPort:(id)sender;
- (IBAction)switchedInClock:(id)sender;
- (IBAction)switchedOutPort:(id)sender;
- (IBAction)switchedOutClock:(id)sender;

- (void)setMidiPorts;
- (void)sessionDidChange:(NSNotification *)note;

- (UITableViewCell *)globalCells:(UITableViewCell *)cell row:(NSUInteger)row;
- (UITableViewCell *)addPortCell:(UITableViewCell *)cell name:(NSString *)device port:(int)port latency:(float)ms input:(BOOL)input;
- (UITableViewCell *)midiCells:(UITableViewCell *)cell row:(NSUInteger)row;
- (UITableViewCell *)networkCells:(UITableViewCell *)cell row:(NSUInteger)row;
- (UITableViewCell *)acceptCells:(UITableViewCell *)cell row:(NSUInteger)row;
- (UITableViewCell *)connectionCells:(UITableViewCell *)cell row:(NSUInteger)row;

@end
