//
//  NotebookTableViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "NotebookTableViewController.h"
#import "UserSettings.h"
#import "EvernoteSDK.h"
#import "MBProgressHUD.h"

@implementation NotebookTableViewController {
    __strong NSArray *_notebooksList;
    NSInteger _notebooksNum;
}

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
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        _notebooksList = notebooks;
        _notebooksNum = [_notebooksList count];
        [[self tableView] reloadData];

        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }                           failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];

        NSString *title = NSLocalizedString(@"NotebookSettingLoginErrorTitle", @"Login error Title for NotebookSetting");
        NSString *errorMessage = NSLocalizedString(@"NotebookSettingLoginError", @"Login error for NotebookSetting");
        UIAlertView *alertDone =
                [[UIAlertView alloc] initWithTitle:title
                                           message:errorMessage
                                          delegate:self
                                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alertDone show];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _notebooksList = nil;
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
    return _notebooksNum;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    EDAMNotebook *notebook = (EDAMNotebook *) [_notebooksList objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[notebook name]];

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 呼び出し元のコントローラーを無理矢理取得する
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EDAMNotebook *notebook = (EDAMNotebook *) [_notebooksList objectAtIndex:[indexPath row]];
    [[UserSettings sharedInstance] setEvernoteNotebookName:notebook.name];
    [[UserSettings sharedInstance] setEvernoteNotebookGUID:notebook.guid];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
