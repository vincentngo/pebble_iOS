//
//  ViewController.m
//  Fuse
//
//  Created by Vincent Ngo on 2/15/14.
//  Copyright (c) 2014 Vincent Ngo. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()



@end

static NSString * const CardsServiceType = @"cards-service";


@implementation ViewController


- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    self.lastPeerInfo = peerID.displayName;
    
    NSLog(@"displayName: %@", self.lastPeerInfo);
    NSArray *parts = [self.lastPeerInfo componentsSeparatedByString:@"|"];
    if (parts.count == 2)
    {
        self.lastContactName = parts[0];
        self.lastContactPhone = parts[1];
        
        NSLog(@"lastContactName: %@", self.lastContactName);
                NSLog(@"lastContactPhone: %@", self.lastContactPhone);
    }
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    
}




#pragma mark - App Messages



#pragma mark - AppSync

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
 
    
    self.personalProfile = [[NSUserDefaults standardUserDefaults] objectForKey:@"profile"];
    NSLog(@"after i clicked it: %@", self.personalProfile);
    
	self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.connectedWatch = self.appDelegate.connectedWatch;
    
    //Check if Launch was sucessful
    [self.connectedWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
            if (!error) {
                NSLog(@"Successfully launched app.");
            }
            else {
                NSLog(@"Error launching app - Error: %@", error);
            }
        }
     ];
    
    
    [self.connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update)
    {
        if ([self.lastContactName length] == 0)
        {
            NSLog(@"No contacts found in area.");
            return NO;
        }
        NSLog(@"recieve %@", self.lastContactName);
        
//        NSDictionary *pebbleUpdate = @{@"Name": self.lastContactName };
        NSDictionary *pebbleUpdate = @{@1: self.lastContactName };
        [self.connectedWatch appMessagesPushUpdate:pebbleUpdate onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            
            if(!error)
            {
                NSLog(@"Succesfuly sent to the pebble!");
            }
            else
            {
                NSLog(@"Failed to send to the Pebble");
            }
            
        }];
        
        
        return YES;
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setup
{
//    self.personalProfile = [[NSUserDefaults standardUserDefaults] objectForKey:@"profile"];
//    NSLog(@"In setup, user defaults (personal profile): %@", self.personalProfile);
    
    NSString *displayName = [NSString stringWithFormat:@"%@|%@", self.personalProfile[@"name"], self.personalProfile[@"phoneNumber"]];
    
    NSLog(@"ViewController.m setup method called because awakeFromNib.");
    // setup peer ID
    self.myPeerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    // setup session
    self.mySession = [[MCSession alloc] initWithPeer:self.myPeerID];
    self.mySession.delegate = self;
    
    self.nearbyBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.myPeerID serviceType:CardsServiceType];
    self.nearbyBrowser.delegate = self;
    [self.nearbyBrowser startBrowsingForPeers];
    
    // setup advertiser
    self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:CardsServiceType discoveryInfo:nil session:self.mySession];
    [self.advertiser start];
    
    //[self.browseButton addTarget:self action:@selector(showBrowserVC) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];

    
}


-(void)awakeFromNib
{
    NSLog(@"called awakeFromNib");
}



/*
 
 To communicate between the mobile app and your watchapp, you use the appMessagePushUpdate:onSent: and appMessagesAddReceiveUpdateHandler: methods discussed in this section.
 */
- (IBAction)test1:(id)sender {
    
    NSDictionary *update = @{ @(0):[NSNumber numberWithUint8:42],
                              @(1):@"a string" };
    


}

- (IBAction)test2:(id)sender {
}


-(void)viewWillAppear:(BOOL)animated
{

    [self.sendButton addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.personalProfile = [[NSUserDefaults standardUserDefaults] objectForKey:@"profile"];
}



- (void) receiveMessage: (NSString *) message fromPeer: (MCPeerID *) peer
{
    NSLog(@"Calling receiveMessage: fromPeer: method");
    self.resultMsg = [message copy];
    self.rxLabel.text = self.resultMsg;
    [self.rxLabel setNeedsDisplay];
    
}

- (void) sendText
{
    NSLog(@"Calling sendText method");
    NSString *message = [[UIDevice currentDevice] name];
    //  Convert text to NSData
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //  Send data to connected peers
    NSError *error;
    [self.mySession sendData:data toPeers:[self.mySession connectedPeers] withMode:MCSessionSendDataUnreliable error:&error];
}

#pragma marks MCSessionDelegate
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {}


/*  First endpoint for data being received. Routes it over to receiveMessage:fromPeer: */
- (void) session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    //  Decode data back to NSString
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //  append message to text box on main thread
    dispatch_async(dispatch_get_main_queue(),^{
        [self receiveMessage: message fromPeer: peerID];
    });
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"performing push segue...");
}


@end
