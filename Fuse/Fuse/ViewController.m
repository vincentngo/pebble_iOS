//
//  ViewController.m
//  Fuse
//
//  Created by Vincent Ngo on 2/15/14.
//  Copyright (c) 2014 Vincent Ngo. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic, strong) NSMutableDictionary *myContacts;
@property (nonatomic, strong) NSMutableArray *listOfContacts;

@end

static NSString * const CardsServiceType = @"cards-service";


@implementation ViewController


- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    self.lastPeerInfo = peerID.displayName;
    
    NSLog(@"FOUND PEER WITH displayName: %@", self.lastPeerInfo);
    NSArray *parts = [self.lastPeerInfo componentsSeparatedByString:@"|"];
    if (parts.count == 2)
    {
        self.lastContactName = parts[0];
        self.lastContactPhone = parts[1];
        NSLog(@"Adding to collection peer with name: %@ and phone: %@", self.lastContactName, self.lastContactPhone);
        if (self.collectedPeers)
        {
            [self.collectedPeers addObject:peerID];
        }
        else
            self.collectedPeers = [[NSMutableArray alloc] initWithObjects:peerID, nil];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    if (!self.collectedPeers) return;
    
    for (MCPeerID *pID in self.collectedPeers)
    {
        if ([pID.displayName isEqualToString:peerID.displayName])
            [self.collectedPeers removeObject:pID];
    }
}


#pragma mark - App Messages



#pragma mark - AppSync

-(NSString *)getNameFromPeerID:(MCPeerID *)peerID
{
    NSArray *parts = [peerID.displayName componentsSeparatedByString:@"|"];
    return parts[0];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    
    self.myContacts = [[NSMutableDictionary alloc] init];
    self.listOfContacts = [[NSMutableArray alloc]init];
    self.personalProfile = [[NSUserDefaults standardUserDefaults] objectForKey:@"profile"];
    
	self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.connectedWatch = self.appDelegate.connectedWatch;
    
    //Check if Launch was sucessful
    [self.connectedWatch appMessagesLaunch:^(PBWatch *watch, NSError *error)
    {
            if (!error) {
                NSLog(@"Successfully launched app.");
            }
            else {
                NSLog(@"Error launching app - Error: %@", error);
            }
    }];
    
    
    [self.connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update)
    {
        NSLog(@"Inside AppMessage Receive Handler. Received NSDictionary update: %@", update);

        
        
        /*
         * Receive the update dictionary from the Pebbble. Update NSDictionary could either be:
         * 1. A dict with one key = [NSNumber 1] and value "GetPeers"
         * 2. A dict with one key = [NSNumber 1] and value = selected name from the peers list shown on the pebble (string)
         */
        
        // Grab the first value from the dictionary
        NSString *firstValue = [update objectForKey:[NSNumber numberWithInteger:1]];
        bool askingForPeers = [firstValue isEqualToString:@"GetPeers"];
        
        NSMutableDictionary *pebbleUpdate = [[NSMutableDictionary alloc] init];
        
        if (askingForPeers)
        {

            /* Send the most recently collected peers (just their names) */
            if (self.collectedPeers && [self.collectedPeers count])
            {
                    
                for (int i = 0; i < self.collectedPeers.count && self.collectedPeers.count < 3; i++)
                {
                    MCPeerID *pID = self.collectedPeers[i];
                    NSNumber *key = [NSNumber numberWithInteger:i+1];
                    NSString *justName = [self getNameFromPeerID:pID];
                    [pebbleUpdate setObject:justName forKey:key];
                }

            }
            else
            {
                [pebbleUpdate setObject:@"NoneFound" forKey:[NSNumber numberWithInteger:-1]];
            }
        }
        else /* Asking to add a specific name to contacts */
        {
            // first value holds the contact name
            NSLog(@"Pebble has asked to save the contact %@", firstValue);
            
            // If we're here, the watchapp selected a peer from the list, sent back the name, and now waits for a success indication.
            // We must: send back value NSNumber 1 (found at key NSNumber 1) to indicate success
            [pebbleUpdate setObject:[NSNumber numberWithInteger:0] forKey:[NSNumber numberWithInteger:1]];
            
            [self.myContacts setObject:[self getPhoneNumber:firstValue] forKey:firstValue];
            [self.listOfContacts addObject:firstValue];
            [self.tableView reloadData];
        }
        
        NSLog(@"Sending AppMessage with a NSDictionary message: %@", pebbleUpdate);
        [self.connectedWatch appMessagesPushUpdate:pebbleUpdate onSent:^(PBWatch *watch, NSDictionary *update, NSError *error)
        {
            if(error)
                NSLog(@"Failed to send to the Pebble!");
            else
                NSLog(@"Succesfuly sent to the pebble!");
        }];
        
        return YES;
    }];
    
}

-(NSString *)getPhoneNumber:(NSString *)name
{
    for (MCPeerID *pID in self.collectedPeers)
    {
        NSArray * parts = [pID.displayName componentsSeparatedByString:@"|"];

        NSLog(@"going over this pID = %@", pID.displayName);
        
        if ([pID.displayName isEqualToString:parts[0]])
        {
            return parts[1];
        }
    }
    return @"";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setup
{
    
    NSString *displayName = [NSString stringWithFormat:@"%@|%@", self.personalProfile[@"name"], self.personalProfile[@"phoneNumber"]];
    
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


#pragma mark- Table view 

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"number row %d", [self.myContacts count]);
    return [self.myContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSInteger row = [indexPath row];
    NSString *name = [self.listOfContacts objectAtIndex:row];
    NSString *number = [self.myContacts objectForKey:name];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    NSLog(@"number is %@", number);
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", number];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */



@end
