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
@property (nonatomic, strong) PBWatch *connectedWatch;

@end

@implementation ViewController

#pragma mark - App Messages



#pragma mark - AppSync

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    
    [self.connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
        NSLog(@"Received message: %@", update);
        return YES;
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 
 To communicate between the mobile app and your watchapp, you use the appMessagePushUpdate:onSent: and appMessagesAddReceiveUpdateHandler: methods discussed in this section.
 */
- (IBAction)test1:(id)sender {
    
    NSDictionary *update = @{ @(0):[NSNumber numberWithUint8:42],
                              @(1):@"a string" };
    
    [self.connectedWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        
        if(!error)
        {
             NSLog(@".... Success");
        }
        else
        {
            NSLog(@".... fail");
        }

    }];
    
//    [self.connectedWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
//        if (!error) {
//            NSLog(@"Successfully sent message.");
//        }
//        else {
//            NSLog(@"Error sending message: %@", error);
//        }
//    }];
}

- (IBAction)test2:(id)sender {
}
@end
