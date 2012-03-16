//
//  AccountSettingViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AccountSettingViewController.h"

#import "EvernoteAuthToken.h"
#import "UserSettings.h"
#import "id.h"
#import "MBProgressHUD.h"
#import "ApplicationError.h"


@implementation AccountSettingViewController

@synthesize userId = _userId;
@synthesize password = _password;

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
    
    _userId.delegate = self;
    _password.delegate = self;
}

- (void)viewDidUnload
{
    _userId = nil;
    _password = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_userId setText:[UserSettings sharedInstance].evernoteUserId];
    [_password setText:[UserSettings sharedInstance].evernotePassword];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)loginEvernote:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = NSLocalizedString(@"AccountSettingLogin", @"Login for AccountSetting");

    NSString *alertTitle = NSLocalizedString(@"AccountSettingLoginTitle", @"Login title for AccountSetting");
    @try {
        [[EvernoteAuthToken sharedInstance] connectWithUserId:_userId.text
                                                     Password:_password.text
                                                   ClientName:APPLICATIONNAME
                                                  ConsumerKey:CONSUMERKEY
                                               ConsumerSecret:CONSUMERSECRET];
        
        [[UserSettings sharedInstance] setEvernoteUserId:_userId.text];
        [[UserSettings sharedInstance] setEvernotePassword:_password.text];
        [[UserSettings sharedInstance] setEvernoteNotebookName:@""];
        [[UserSettings sharedInstance] setEvernoteNotebookGUID:@""];
        
        UIAlertView *alertDone =
        [[UIAlertView alloc] initWithTitle:alertTitle
                                   message:NSLocalizedString(@"AccountSettingLoginSucceeded", @"Login succeeded for AccountSetting")
                                  delegate:self
                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                         otherButtonTitles: nil];
        [alertDone show];
    }
    @catch (NSException *exception) {
        NSLog(@"PhotoUploader exception:%@", [exception reason]);
        UIAlertView *alertDone =
        [[UIAlertView alloc] initWithTitle:alertTitle
                                   message:NSLocalizedString(@"AccountSettingLoginFailed", @"Login failed for AccountSetting")
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                         otherButtonTitles: nil];
        [alertDone show];

        return;
    }
    @finally {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
