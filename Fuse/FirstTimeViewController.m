//
//  FirstTimeViewController.m
//  Fuse
//
//  Created by Vincent Ngo on 2/15/14.
//  Copyright (c) 2014 Vincent Ngo. All rights reserved.
//

#import "FirstTimeViewController.h"
#import "ViewController.h"

@interface FirstTimeViewController ()

@end

@implementation FirstTimeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startSharing:(id)sender {
    
    NSDictionary *dict = @{@"name": self.textFieldName.text, @"phoneNumber": self.textFieldNumber.text};
    
    //Save your profile in standardUserDefaults
    [[NSUserDefaults standardUserDefaults]
     setObject:dict forKey:@"profile"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    [self performSegueWithIdentifier:@"startSending" sender:sender];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"startSending"]) {
//        
//        // Get destination view
//        ViewController *vc = [segue destinationViewController];
//        
//    
//    }
//}
@end