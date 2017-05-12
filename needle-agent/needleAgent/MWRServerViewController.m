//
//  MWRServerViewController.m
//  needleAgent
//

#import "MWRServerViewController.h"
#import "Constants.h"
#import "Utils.h"

@implementation MWRServerViewController

// ---------------------------------------------------------------------------
// UI
// ---------------------------------------------------------------------------
// Use this initaliser because View Controller is called from Storyboard
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    // Sockets will run on seperate thread/queue to UI
    self.socketQueue = dispatch_queue_create("socketQueue", NULL);
    self.listenerSocket = [[MWRAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
    
    // Keeps track of new client sockets and stops them getting instantly deallocated
    self.connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    
    self.responsesString = [NSMutableString string];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Update standard port
    self.portTextField.text = [NSString stringWithFormat:@"%@", DEFAULT_PORT];
    
    // Update versionLabel
    self.versionLabel.text = [NSString stringWithFormat:@"v.%@", AGENT_VERSION];
    
    // Update IP label
    self.IPLabel.text = [NSString stringWithFormat:@"(IP: %@)", [Utils getIPAddress]];
    
    // Allow number keyboard to be dismissed by tapping outside the keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard
{
    [self.portTextField resignFirstResponder];
}

-(void)updateLogs:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Prepend to responses string so messages appear at top of screen
        self.responsesString = [NSString stringWithFormat:@"> %@\n%@", message, self.responsesString];
        
        // Update UILabel with new responses
        self.responsesLabel.text = self.responsesString;
        
        // Update IP label
        self.IPLabel.text = [NSString stringWithFormat:@"(IP: %@)", [Utils getIPAddress]];
    });
}


// ---------------------------------------------------------------------------
// AGENT SERVER
// ---------------------------------------------------------------------------
-(void)listen:(UISwitch *)s
{
    // Setup port
    int port = [self.portTextField.text intValue];
    if(port < 1025 || port > 65535) self.portTextField.text = DEFAULT_PORT;
    // Check for errors
    NSError *error = nil;
    if (![self.listenerSocket acceptOnPort:port error:&error])
    {
        [self updateLogs:[NSString stringWithFormat:@"ERROR: %@", error]];
        [s setOn:NO];
    } else {
        [self updateLogs:@"Listening"];
        [self.portTextField setEnabled:NO];
    }
}

-(void)disconnect
{
    // Update UI
    [self.portTextField setEnabled:YES];
    // Stop any client connections
    [self.listenerSocket disconnect];
    @synchronized(self.connectedSockets)
    {
        NSUInteger i;
        for (i = 0; i < [self.connectedSockets count]; i++)
        {
            // Call disconnect on the socket,
            // which will invoke the socketDidDisconnect: method,
            // which will remove the socket from the list.
            [[self.connectedSockets objectAtIndex:i] disconnect];
        }
    }
    [self updateLogs:@"Stopped Listening"];
}

- (IBAction)startStop:(id)sender
{
    // Starts and stops socket listening
    UISwitch *s = (UISwitch *)sender;
    if
        ([s isOn]) [self listen:s];
    else
        [self disconnect];
}

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    @synchronized(self.connectedSockets)
    {
        if([self.connectedSockets count] > 0)
        {
            // We already have a client connected, reject the request
            [self updateLogs:[NSString stringWithFormat:@"A client is already connected, rejecting new connection request from: %@",
                              newSocket.connectedHost]];
            return;
        }
        else
        {
            // First connection, accept it
            [self.connectedSockets addObject:newSocket];
        }
    }
    [newSocket performBlock:^{
        [newSocket enableBackgroundingOnSocket];
    }];
    [sender performBlock:^{
        [sender enableBackgroundingOnSocket];
    }];
    
    // Send welcome string to client
    [self updateLogs:[NSString stringWithFormat:@"New connection from: %@", newSocket.connectedHost]];
    NSString *welcomeMsg = AGENT_WELCOME;
    NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    [newSocket writeData:welcomeData withTimeout:-1 tag:1];
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
    // Send version to client
    NSData *versionData = [[NSString stringWithFormat:@"\n%@: %@\n", COMMAND_VERSION, AGENT_VERSION] dataUsingEncoding:NSUTF8StringEncoding];
    [newSocket writeData:versionData withTimeout:-1 tag:1];
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(nonnull NSData *)data withTag:(long)tag
{
    // Strip extra newline
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *request = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    // Update Logs
    if ([request length] > 0)
    {
        [self updateLogs:[NSString stringWithFormat:@"[%@] OPCODE: %@", sock.connectedHost, request]];
        // Handle OPCODE
        NSString *msg = [((MWRAsyncSocket *)sock).handler handleCommand:request];
        if([msg isEqualToString:COMMAND_DISCONNECT]){
            [sock disconnect];
            return;
        }
        [(MWRAsyncSocket *)sock writeString:msg withCRLF:YES];
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:1];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock != self.listenerSocket)
    {
        [self updateLogs:@"Client Disconnected"];
        @synchronized(self.connectedSockets)
        {
            [self.connectedSockets removeObject:sock];
        }
    }
}

@end
