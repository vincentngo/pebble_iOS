//
//  FirstTimeViewController.h
//  Fuse
//
//  Created by Vincent Ngo and Carlos Folgar on 2/15/14.
//  Copyright (c) 2014 Vincent Ngo and Carlos Folgar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstTimeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *textFieldName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldNumber;
- (IBAction)startSharing:(id)sender;

@end
