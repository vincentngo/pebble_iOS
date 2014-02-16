//
//  ViewController.h
//  Fuse
//
//  Created by Vincent Ngo on 2/15/14.
//  Copyright (c) 2014 Vincent Ngo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController <MCNearbyServiceAdvertiserDelegate, UIActionSheetDelegate,
MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCBrowserViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *rxLabel;
@property (weak, nonatomic) IBOutlet UIButton *browseButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) NSMutableArray * mutableBlockedPeers;


@property (nonatomic, strong) NSArray *lastResultArray;
@property (nonatomic, strong) MCBrowserViewController *browserVC;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *nearbyBrowser;
@property (nonatomic, strong) MCSession *mySession;
@property (nonatomic, strong) MCPeerID *myPeerID;

@property (strong, nonatomic) NSString * resultMsg;


// Example peerid.displayName = "Carlos Folgar|5408086728"
@property (strong, nonatomic) NSString * lastPeerInfo;

@property (strong, nonatomic) NSString * lastContactName;
@property (strong, nonatomic) NSString * lastContactPhone;

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) PBWatch *connectedWatch;
@property (nonatomic, strong) NSDictionary *personalProfile;

@end
