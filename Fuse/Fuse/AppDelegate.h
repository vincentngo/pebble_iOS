//
//  AppDelegate.h
//  Fuse
//
//  Created by Vincent Ngo and Carlos Folgar on 2/15/14.
//  Copyright (c) 2014 Vincent Ngo and Carlos Folgar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PBPebbleCentralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PBWatch *connectedWatch;


//TODO:
/*
 Important
 The maximum buffer size for AppMessage is currently 124 bytes. This means that no messages that you send or receive can be bigger than 124 bytes once transformed into a Pebble Dictionary object.
 You will need to split your data in smaller chunks if you want to send a larger volume of data.
 */
@end
