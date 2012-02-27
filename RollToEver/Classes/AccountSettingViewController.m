//
//  AccountSettingViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AccountSettingViewController.h"

#import "Evernote.h"
#import "UserSettings.h"
#import "SettingsTableViewController.h"

@implementation AccountSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userId.delegate = self;
    password.delegate = self;
}

- (void)viewDidUnload
{
    [userId release];
    userId = nil;
    [password release];
    password = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [userId setText:[UserSettings sharedInstance].evernoteUserId];
    [password setText:[UserSettings sharedInstance].evernotePassword];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UserSettings sharedInstance] setEvernoteUserId:userId.text];
    [[UserSettings sharedInstance] setEvernotePassword:password.text];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [userId release];
    [password release];
    [super dealloc];
}

- (IBAction)testConnection:(id)sender {
    Evernote *evernote = nil;
    @try {
        evernote = [[Evernote alloc]
                    initWithUserId:userId.text
                    Password:password.text];
        [evernote connect];
    }
    @catch (EDAMUserException * e) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error Evernote connect: error code %i", [e errorCode]];
        UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle: @"Evernote" message: errorMessage delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        
        [alertDone show];
        [alertDone release];
        return;
    }
    @finally {
        [evernote release];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

@end
