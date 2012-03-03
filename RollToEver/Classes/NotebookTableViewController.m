//
//  NotebookTableViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "NotebookTableViewController.h"

#import "SettingsTableViewController.h"
#import "UserSettings.h"
#import "EvernoteAuthToken.h"
#import "EvernoteNoteStoreClient.h"
#import "id.h"
#import "MBProgressHUD.h"

@implementation NotebookTableViewController

NSArray *notebooksList_;
NSInteger notebooksNum_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = NSLocalizedString(@"Loading", @"Now Loading");
    
    // Evernoteにログインしてなかったらとりあえずログイン
    if ([EvernoteAuthToken sharedInstance].authToken == nil) {
        NSString *userid = [UserSettings sharedInstance].evernoteUserId;
        NSString *password = [UserSettings sharedInstance].evernotePassword;
        bool ret = [[EvernoteAuthToken sharedInstance] connectWithUserId:userid
                                                                Password:password
                                                              ClientName:APPLICATIONNAME
                                                             ConsumerKey:CONSUMERKEY
                                                          ConsumerSecret:CONSUMERSECRET];
        if (!ret) {
            NSString *title = NSLocalizedString(@"NotebookSettingLoginErrorTitle", @"Login error Title for NotebookSetting");
            NSString *errorMessage = NSLocalizedString(@"NotebookSettingLoginError", @"Login error for NotebookSetting");
            UIAlertView *alertDone =
                [[UIAlertView alloc] initWithTitle:title
                                           message:errorMessage
                                          delegate:self
                                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                 otherButtonTitles: nil];
            [alertDone show];
            [alertDone release];
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [[self navigationController] popViewControllerAnimated:YES];

            return;
        }
    }
    
    EvernoteNoteStoreClient *client = [[[EvernoteNoteStoreClient alloc] init] autorelease];
    NSString *authToken = [EvernoteAuthToken sharedInstance].authToken;
    notebooksList_ = [[NSArray alloc] initWithArray:[[client noteStoreClient] listNotebooks:authToken]];
    notebooksNum_ = [notebooksList_ count];
    [[self tableView] reloadData];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [notebooksList_ release];
    notebooksList_ = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notebooksNum_;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"NotebookSettingTitle", @"Table Title for NotebookSetting");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    EDAMNotebook *notebook = (EDAMNotebook *)[notebooksList_ objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[notebook name]];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 呼び出し元のコントローラーを無理矢理取得する
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EDAMNotebook *notebook = (EDAMNotebook *)[notebooksList_ objectAtIndex:[indexPath row]];
    [[UserSettings sharedInstance] setEvernoteNotebookName:notebook.name];
    [[UserSettings sharedInstance] setEvernoteNotebookGUID:notebook.guid];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
