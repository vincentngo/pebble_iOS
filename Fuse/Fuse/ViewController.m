//
//  ViewController.m
//  Fuse
//
//  Created by Vincent Ngo on 2/15/14.
//  Copyright (c) 2014 Vincent Ngo. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
- (IBAction)test1:(id)sender;
- (IBAction)test2:(id)sender;

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

static NSString * const CardsServiceType = @"cards-service";


@implementation ViewController


- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"browser found peer %@ with discovery info : %@", peerID.displayName, info);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setup
{
    
    NSLog(@"ViewController.m setup method called because awakeFromNib.");
    // setup peer ID
    self.myPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
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
    [self setup];
}

- (IBAction)test1:(id)sender {
}

- (IBAction)test2:(id)sender {
}


-(void)viewWillAppear:(BOOL)animated
{
//    [self.browseButton addTarget:self action:@selector(showBrowserVC) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewDidAppear:(BOOL)animated
{
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

// presents the VC that shows nearby beacons
//-(void) showBrowserVC
//{
//    NSLog(@"attempting to showBrowserVC");
//    [self presentViewController:self.browserVC animated:YES completion:nil];
//}

// dismisses VC presented above
//- (void) dismissBrowserVC { [self.browserVC dismissViewControllerAnimated:YES completion:nil]; }

#pragma marks MCBrowserViewControllerDelegate

// Notifies the delegate, when the user taps the done button
//- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController { [self dismissBrowserVC]; }

// Notifies delegate that the user taps the cancel button.
//- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController { [self dismissBrowserVC]; }

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
