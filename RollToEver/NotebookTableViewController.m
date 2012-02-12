//
//  NotebookTableViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "NotebookTableViewController.h"

#import "SettingsTableViewController.h"
#import "Evernote.h"
#import "UserSettings.h"

@implementation NotebookTableViewController

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

    Evernote *evernote = nil;
    @try {
        evernote = [[Evernote alloc]
                    initWithUserID:[UserSettings sharedInstance].evernoteUserId
                    Password:[UserSettings sharedInstance].evernotePassword];
        notebooksList_ = [evernote listNotebooks];
        notebooksNum_ = [notebooksList_ count];
    }
    @catch (EDAMUserException * e) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error listing note: error code %i", [e errorCode]];
        UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle: @"Evernote" message: errorMessage delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        
        [alertDone show];
        [alertDone release];
        return;
    }
    @finally {
        [evernote release];
    }
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
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return @"Choose Notebook";
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
    NSArray *array = self.navigationController.viewControllers;
    int arrayCount = [array count];
    SettingsTableViewController *parent = [array objectAtIndex:arrayCount - 2];

    EDAMNotebook *notebook = (EDAMNotebook *)[notebooksList_ objectAtIndex:[indexPath row]];

    parent.notebookName = notebook.name;
    [[UserSettings sharedInstance] setEvernoteNotebookName:notebook.name];
    [[UserSettings sharedInstance] setEvernoteNotebookGUID:notebook.guid];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
