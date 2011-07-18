//
//  MIDIController.m
//  Molten
//
//  Created by Peter Johnson on 02/12/10.
//  Copyright 2010 One Red Dog Media Pty Ltd Media Pty Ltd. All rights reserved.
//

#import "MIDIController.h"
#include <GSMain.h>
#include <Mac_MIDI_scheduler.h>
#include <MIDI_command.h>
#import <QuartzCore/QuartzCore.h>

#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation MIDIController

#pragma mark -
#pragma mark Initialization

const int GLOBAL_SECTION = 0;
const int MIDI_PORTS_SECTION = 1;
const int NETWORK_DRIVER_SECTION = 2;
const int ACCEPT_SECTION = 3;
const int CONNECTIONS_SECTION = 4;

@synthesize portNames;
@synthesize inPorts;
@synthesize inClocks;
@synthesize outPorts;
@synthesize outClocks;

@synthesize isConnected;
@synthesize browser;
@synthesize connectedService;
@synthesize services;


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup the table view
    self.contentSizeForViewInPopover = CGSizeMake(605, 700);

    MIDINetworkSession* session = [MIDINetworkSession defaultSession];

    NSMutableSet* set = [[NSMutableSet alloc] initWithSet:session.contacts];
    for (MIDINetworkHost* host in set)
    {
        [session removeContact:host];
    }
    [set release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidChange:) name:MIDINetworkNotificationSessionDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidChange:) name:MIDINetworkNotificationContactsDidChange object:nil];    

    // Start Bonjour browser
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion > 4.2)
    {
        services = [[NSMutableArray alloc] init];
        browser = [[NSNetServiceBrowser alloc] init];
        [browser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@""];
        browser.delegate = self;
        isConnected = NO;
    }

    inPorts = [[NSMutableArray alloc] init];
    inClocks = [[NSMutableArray alloc] init];
    outPorts = [[NSMutableArray alloc] init];
    outClocks = [[NSMutableArray alloc] init];

    [self setMidiPorts];
    
    [self connectionsTable];
}

-(void)viewWillDisappear:(BOOL)animate
{
    [browser stop];
	[super viewWillDisappear:NO];
}

- (void)viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [portNames release];
    portNames = nil;
    [inPorts release];
    inPorts = nil;
    [inClocks release];
    inClocks = nil;
    [outPorts release];
    outPorts = nil;
    [outClocks release];
    outClocks = nil;
    [browser release];
    [services release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MIDINetworkNotificationSessionDidChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MIDINetworkNotificationContactsDidChange object:nil];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release anything that's not essential, such as cached data
}

- (void)dealloc
{
    [portNames release];
    [inPorts release];
    [inClocks release];
    [outPorts release];
    [outClocks release];
    [browser release];
    [services release];
    [super dealloc];
}

- (void)connectionsTable
{
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 605, 700) style:UITableViewStyleGrouped];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    mTableView.backgroundColor = [UIColor whiteColor];
    mTableView.bounces = NO;
    mTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:mTableView];
    [mTableView reloadData];
    [mTableView release];
}

#pragma Controls selectors

- (IBAction)switchedLocal:(id)sender
{
    UISwitch* current = (UISwitch *) sender;
    GSMain* me = GSMain::Instance();
    me->set_local(current.on);
}

- (IBAction)switchedExtIn:(id)sender
{
    UISwitch* current = (UISwitch *) sender;
    GSMain* me = GSMain::Instance();
    me->set_extin(current.on);

    for (UISwitch* element in outClocks)
    {
        element.enabled = !current.on;
    }
}

- (IBAction)switchedDriver:(id)sender
{
    UISwitch* current = (UISwitch *) sender;
    MIDINetworkSession* session = [MIDINetworkSession defaultSession];
    session.enabled = current.on;
}

- (IBAction)switchedNetAccept:(id)sender
{
    UISwitch* current = (UISwitch *) sender;
    MIDINetworkSession* session = [MIDINetworkSession defaultSession];
    session.connectionPolicy = current.on ? MIDINetworkConnectionPolicy_Anyone : MIDINetworkConnectionPolicy_NoOne;
}

- (IBAction)switchedInPort:(id)sender
{
    UIButton* button = (UIButton *)sender;
    button.selected = !button.selected;

	Molten::Mac_MIDI_scheduler* sch = Molten::Mac_MIDI_scheduler::Instance();
    if (button.selected)
    {
        sch->set_port_in(button.tag);
    }
    else
    {
        sch->set_port_in(Molten::MIDI_command::no_port);
    }

    // Only receive on one port at a time
    for (UIButton* element in inPorts)
    {
        if (element != button)
        {
            if (button.selected)
            {
                element.selected = NO;
            }
        }
    }
}

- (IBAction)switchedInClock:(id)sender
{
    UIButton* button = (UIButton *) sender;
    button.selected = !button.selected;

	Molten::Mac_MIDI_scheduler* sch = Molten::Mac_MIDI_scheduler::Instance();
    if (button.selected)
    {
        sch->set_clock_in(button.tag);
    }
    else
    {
        sch->set_clock_in(Molten::MIDI_command::no_port);
    }
	
    // Only receive on one port at a time
    for (UIButton* element in inClocks)
    {
        if (element != button)
        {
            if (button.selected)
            {
                element.selected = NO;
            }
        }
    }
}

- (IBAction)switchedOutPort:(id)sender
{
    UIButton* button = (UIButton *) sender;
    button.selected = !button.selected;

    Molten::Mac_MIDI_scheduler* sch = Molten::Mac_MIDI_scheduler::Instance();
    if (button.selected)
    {
        sch->set_port_out(button.tag);
    }
    else
    {
        sch->set_port_out(Molten::MIDI_command::no_port);
    }

    // Only receive on one port at a time
    for (UIButton* element in outPorts)
    {
        if (element != button)
        {
            if (button.selected)
            {
                element.selected = NO;
            }
        }
    }
}

- (IBAction)switchedOutClock:(id)sender
{
    UIButton* button = (UIButton *) sender;
    button.selected = !button.selected;

	Molten::Mac_MIDI_scheduler* sch = Molten::Mac_MIDI_scheduler::Instance();
    if (button.selected)
    {
        sch->set_clock_out(button.tag);
    }
    else
    {
        sch->set_clock_out(Molten::MIDI_command::no_port);
    }

	GSMain* me = GSMain::Instance();
    me->set_transmitclock(button.selected);
		
	// Only receive clock on one port at a time
    for (UIButton* element in outClocks)
    {
        if (element != button)
        {
            if (button.selected)
            {
                element.selected = NO;
            }
        }
    }
}

// Update available MIDI ports
- (void)setMidiPorts
{
    MIDINetworkSession* session = [MIDINetworkSession defaultSession];

    [portNames release];
    portNames = [[NSMutableArray alloc] init];
    
    // Get MIDI device list
    Molten::Mac_MIDI_scheduler* sch = Molten::Mac_MIDI_scheduler::Instance();
    
    std::vector<int32> port_nums;
    sch->set_port_numbers(port_nums);

    // Get the input port names
    for (size_t index = 0; index < sch->get_num_ports(); ++index)
    {
        int32 port = port_nums[index];
        if (sch->port_readable(port))
        {
            NSString* device = [NSString stringWithFormat:@"%@", [NSString stringWithUTF8String:sch->get_port_name(port)]];
            if (!session.enabled && sch->port_wireless(port))
            {
                // not enabled and this is wireless port, skip it
            }
            else
            {
                [portNames addObject:device];
            }
        }
    }

    [mTableView reloadData];
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

/* useful code to keep around to get address of service
    NSString* localIP = [self getIPAddress];
    for (NSData* data in [service addresses])
    {
        char addressBuffer[100];
        
        struct sockaddr_in* socketAddress = (struct sockaddr_in*) [data bytes];
        
        int sockFamily = socketAddress->sin_family;
        
        if (sockFamily == AF_INET || sockFamily == AF_INET6)
        {
            const char* addressStr = inet_ntop(sockFamily,
                                               &(socketAddress->sin_addr), addressBuffer,
                                               sizeof(addressBuffer));
            
            int port = ntohs(socketAddress->sin_port);
            
            if (addressStr && port)
            {
                NSLog(@"Found service at %s:%d", addressStr, port);
            }
        }
    }
*/
 


#pragma mark MIDINetworkNotificationSessionDidChange notification
- (void)sessionDidChange:(NSNotification *)note
{
    [mTableView reloadData];
}

#pragma mark Net Service Browser Delegate Methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)service moreComing:(BOOL)more
{
    [service retain];
    service.delegate = self;
    [service resolveWithTimeout:5];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)more
{
    if (service == self.connectedService)
    {
        self.isConnected = NO;
    }
    
    MIDINetworkSession* session = [MIDINetworkSession defaultSession];
    MIDINetworkHost* toRemove = nil;
    
    for (MIDINetworkHost* host in session.contacts)
    {
        if ([host.name caseInsensitiveCompare:service.name] == NSOrderedSame)
        {
            toRemove = host;
            break;
        }
    }
    
    [session removeContact:toRemove];
    
    if (session.enabled)
    {
        [mTableView reloadData];
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    NSString *name = service.name;
    NSString* hostName = service.hostName;

    // Don't add the local machine
    NSString* localHostname = [[UIDevice currentDevice] name];

    NSRange textRange = [[hostName lowercaseString] rangeOfString:[localHostname lowercaseString]];

    if (textRange.location == NSNotFound)
    {
        // Now add the device....
        
        MIDINetworkSession* session = [MIDINetworkSession defaultSession];
        MIDINetworkHost* contact = [MIDINetworkHost hostWithName:name netService:service];
        
        BOOL exists = NO;
        for (MIDINetworkHost* host in session.contacts)
        {
            if ([host.name caseInsensitiveCompare:name] == NSOrderedSame)
            {
                exists = YES;
                break;
            }
        }
        if (!exists)
        {
            [session addContact:contact];
        }
        
        if (session.enabled)
        {
            [mTableView reloadData];
        }
    }
    
    [service release];
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"Could not resolve: %@", errorDict);
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    
    if (section == CONNECTIONS_SECTION)
    {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];

        MIDINetworkSession* session = [MIDINetworkSession defaultSession];
        NSUInteger item = 0;
        MIDINetworkHost* host = nil;
        for (host in session.contacts)
        {
            if ([cell.textLabel.text caseInsensitiveCompare:host.name] == NSOrderedSame)
            {
                break;
            }
            item++;
        }
        MIDINetworkConnection* conn = [MIDINetworkConnection connectionWithHost:host];
        
        if (cell.accessoryType == UITableViewCellAccessoryNone)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;

            [session addConnection:conn];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;

            [session removeConnection:conn];
        }
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger number = 3;

    MIDINetworkSession* session = [MIDINetworkSession defaultSession];
    if (session.enabled)
    {
        float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (systemVersion > 4.2)
        {
            number = 5;
        }
        else
        {
            number = 4;
        }
    }
    
    return number;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    switch (section)
    {
        case GLOBAL_SECTION:
        {
            return @"Global Control";
        }
        break;
            
        case MIDI_PORTS_SECTION:
        {
            return @"MIDI Ports";
        }
        break;
            
        case NETWORK_DRIVER_SECTION:
        {
            return @"MIDI Network Driver";
        }
        break;

        case ACCEPT_SECTION:
        {
            return @"";
        }
        break;
            
        case CONNECTIONS_SECTION:
        {
            return @"Connections";
        }
        break;
    }
    
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case GLOBAL_SECTION:
        {
            return @"";
        }
        break;
            
        case MIDI_PORTS_SECTION:
        {
            return @"Enable input/output MIDI port track and clock sync";
        }
        break;
            
        case NETWORK_DRIVER_SECTION:
        {
            return @"Enable to send/receive MIDI over Wi-Fi or Bluetooth";
        }
            break;
            
        case ACCEPT_SECTION:
        {
            return @"Enable to allow any remove host to initiate a connection";
        }
        break;
            
        case CONNECTIONS_SECTION:
        {
            return @"Tap to establish or break connections";
        }
        break;
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case GLOBAL_SECTION:
        {
            return 2;
        }
        break;

        case MIDI_PORTS_SECTION:
        {
            return portNames.count * 2;
        }
        break;
            
        case NETWORK_DRIVER_SECTION:
        {
            return 1;
        }
        break;
            
        case ACCEPT_SECTION:
        {
            return 1;
        }
        break;
            
        case CONNECTIONS_SECTION:
        {
            MIDINetworkSession* session = [MIDINetworkSession defaultSession];
            NSInteger count = session.contacts.count;
            return count == 0 ? 1 : count;
        }
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"ContactCell";

    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    
    switch (section)
    {
        case GLOBAL_SECTION:
        {
            cell = [self globalCells:cell row:row];
        }
        break;
            
        case MIDI_PORTS_SECTION:
        {
            cell = [self midiCells:cell row:row];
        }
        break;
        
        case NETWORK_DRIVER_SECTION:
        {
            cell = [self networkCells:cell row:row];
        }
        break;

        case ACCEPT_SECTION:
        {
            cell = [self acceptCells:cell row:row];
        }
            break;
            
        case CONNECTIONS_SECTION:
        {
            cell = [self connectionCells:cell row:row];
        }
        break;
    }

    return cell;
}

- (UITableViewCell *)globalCells:(UITableViewCell *)cell row:(NSUInteger)row
{
    GSMain* me = GSMain::Instance();

    switch (row)
    {
        case 0:
        {
            cell.textLabel.text = @"Local Control";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            [switchView setOn:me->get_local() animated:NO];
            [switchView addTarget:self action:@selector(switchedLocal:) forControlEvents:UIControlEventValueChanged];
            [switchView release];
        }
        break;
            
        case 1:
        {
            cell.textLabel.text = @"External Sync";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
            [switchView setOn:me->get_extin() animated:NO];
            [switchView addTarget:self action:@selector(switchedExtIn:) forControlEvents:UIControlEventValueChanged];
            [switchView release];
        }
        break;
    }
    
    return cell;
}

- (UITableViewCell *)addPortCell:(UITableViewCell *)cell name:(NSString *)device port:(int)port latency:(float)ms input:(BOOL)input
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    // Text Lables
    cell.textLabel.text = @" ";

    CGRect contentRect = CGRectMake(10, (ms > 0 ? - 8 : 0), 400, 44);
    UILabel* textView = [[UILabel alloc] initWithFrame:contentRect];
	textView.text = device;
	textView.numberOfLines = 1;
	textView.textColor = [UIColor blackColor];
    textView.backgroundColor = [UIColor clearColor];
	textView.font = [UIFont boldSystemFontOfSize:18];
    [cell.contentView addSubview:textView];
	[textView release];

    if (ms > 0)
    {
        UIFont* detailFont = [UIFont systemFontOfSize:14.0];
        UILabel* label2 = [cell detailTextLabel];
        label2.font = detailFont;
        label2.textColor = [UIColor colorWithRed:1.0f green:0.64f blue:0.0f alpha:1.0f];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Latency: %0.fms", ms];
    }

    Molten::Mac_MIDI_scheduler* sch = Molten::Mac_MIDI_scheduler::Instance();

    // Port on/off button
    UIButton* btnPort = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnPort.frame = CGRectMake(445, 3, 60, 40);
    [btnPort setTitle:@"Track" forState:UIControlStateNormal];
    btnPort.tag = port;
    btnPort.backgroundColor = [UIColor clearColor];
	[btnPort setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateSelected];
	[btnPort setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btnPort setTitleShadowColor:[UIColor redColor] forState:UIControlStateNormal];
    if (input)
    {
        btnPort.selected = (port == sch->get_port_in());
        [btnPort addTarget:self action:@selector(switchedInPort:) forControlEvents:UIControlEventTouchUpInside];
        [inPorts addObject:btnPort];
    }
    else
    {
        btnPort.selected = (port == sch->get_port_out());
        [btnPort addTarget:self action:@selector(switchedOutPort:) forControlEvents:UIControlEventTouchUpInside];
        [outPorts addObject:btnPort];
    }
    [cell addSubview:btnPort];
    
    // Clock on/off button
    UIButton* btnClock = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnClock.frame = CGRectMake(0, 0, 60, 40);
    [btnClock setTitle:@"Clock" forState:UIControlStateNormal];
    btnClock.tag = port;
    btnClock.backgroundColor = [UIColor clearColor];
	[btnClock setBackgroundImage:[UIImage imageNamed:@"ButtonBack.png"] forState:UIControlStateSelected];
	[btnClock setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    cell.accessoryView = btnClock;
    if (input)
    {
        btnClock.selected = (port == sch->get_clock_in());
        [btnClock addTarget:self action:@selector(switchedInClock:) forControlEvents:UIControlEventTouchUpInside];
        [inClocks addObject:btnClock];
    }
    else
    {
        btnClock.selected = (port == sch->get_clock_out());
        [btnClock addTarget:self action:@selector(switchedOutClock:) forControlEvents:UIControlEventTouchUpInside];
        [outClocks addObject:btnClock];
    }
    
    return cell;
}

- (UITableViewCell *)midiCells:(UITableViewCell *)cell row:(NSUInteger)row
{
    Molten::Mac_MIDI_scheduler* sch = Molten::Mac_MIDI_scheduler::Instance();

    // Initialize the array.
    std::vector<int32> port_nums;
    sch->set_port_numbers(port_nums);

    // Get output port names
    // Match them to input
    NSString* device;
    NSString* iter = [portNames objectAtIndex:(row % portNames.count)];
    
    if (iter != nil)
    {
        for (size_t index = 0; index < sch->get_num_ports(); ++index)
        {
            int32 port = port_nums[index];
            NSString* name = [NSString stringWithUTF8String:sch->get_port_name(port)];
            float32 ms = sch->port_latency(port);
            
            if (row < portNames.count)
            {
                if (sch->port_readable(port))
                {
                    if ([iter isEqualToString:name])
                    {
                        device = [NSString stringWithFormat:@"Input: %@\n", name];
                        cell = [self addPortCell:cell name:device port:port latency:ms input:YES];
                    }
                }
            }
            else
            {
                if (sch->port_writeable(port))
                {
                    if ([iter isEqualToString:name])
                    {
                        device = [NSString stringWithFormat:@"Output: %@\n", name];
                        cell = [self addPortCell:cell name:device port:port latency:ms input:NO];
                    }
                }
            }
        }
    }
    
    return cell;
}

- (UITableViewCell *)networkCells:(UITableViewCell *)cell row:(NSUInteger)row
{
    MIDINetworkSession* session = [MIDINetworkSession defaultSession];

    cell.textLabel.text = @"Default Session";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = switchView;
    [switchView setOn:session.enabled animated:NO];
    [switchView addTarget:self action:@selector(switchedDriver:) forControlEvents:UIControlEventValueChanged];
    [switchView release];

    return cell;
}

- (UITableViewCell *)acceptCells:(UITableViewCell *)cell row:(NSUInteger)row
{
    MIDINetworkSession* session = [MIDINetworkSession defaultSession];

    cell.textLabel.text = @"Accept Connections";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = switchView;
    [switchView setOn:session.enabled animated:NO];
    [switchView addTarget:self action:@selector(switchedNetAccept:) forControlEvents:UIControlEventValueChanged];
    switchView.enabled = session.enabled;
    [switchView release];
    
    return cell;
}

- (UITableViewCell *)connectionCells:(UITableViewCell *)cell row:(NSUInteger)row
{
    cell.accessoryType = UITableViewCellAccessoryNone;

    MIDINetworkSession* session = [MIDINetworkSession defaultSession];
 
    if (session.contacts.count == 0)
    {
        cell.textLabel.text = @"Searching...";
        cell.textLabel.textColor = [UIColor grayColor];
        
        UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = spinner;
        [spinner startAnimating];
        [spinner release];
    }
    else
    {
        for (MIDINetworkHost* host in session.contacts)
        {
            cell.textLabel.text = host.name;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            for (MIDINetworkConnection* conn in session.connections)
            {
                if ([host.name isEqualToString:host.name])
                {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
        }
    }
    
    return cell;
}

@end
