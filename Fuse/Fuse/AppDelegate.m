//
//  AppDelegate.m
//  Fuse
//
//  Created by Vincent Ngo and Carlos Folgar on 2/15/14.
//  Copyright (c) 2014 Vincent Ngo and Carlos Folgar. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //NOTE: PBPebbleCentral is a singleton.
    self.connectedWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    NSLog(@"Last connected watch: %@", self.connectedWatch);
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    //Setup UUID for companion app for pebble.
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"39b3d511-5de7-44b6-a399-be4b138b83ec"];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];

    //Check if pebble supports app messages.
    [self.connectedWatch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            NSLog(@"This Pebble supports app message!");
        }
        else {
            NSLog(@":( - This Pebble does not support app message!");
        }
    }];
    

    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - PBPebbleCentral Delegate

//TODO: get the list of connected Pebbles at startup, use [[PBPebbleCentral defaultPebbleCentral] connectedWatches] or lastConnectedWatch.

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    
    //Check if pebble has connected for the first time.
    if (isNew)
    {
        NSLog(@"First-time new connections");
    }
    
    NSLog(@"Pebble connected: %@", [watch name]);
    self.connectedWatch = watch;
    
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Pebble disconnected: %@", [watch name]);
    
    if (self.connectedWatch == watch || [watch isEqual:self.connectedWatch]) {
        self.connectedWatch = nil;
    }
    
}





@end
