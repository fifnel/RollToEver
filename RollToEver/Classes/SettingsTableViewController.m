//
//  SettingsTableViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "SettingsTableViewController.h"

#import "UserSettings.h"
#import "AssetURLStorage.h"
#import "AssetsLoader+Utils.h"
#import "MBProgressHUD.h"

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [notebookNameCell_ release];
    [evernoteAccountCell_ release];
    [super dealloc];
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
    notebookNameCell_ = nil;
    evernoteAccountCell_ = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *evernoteAccount = [UserSettings sharedInstance].evernoteUserId;
    NSString *notebookName = [UserSettings sharedInstance].evernoteNotebookName;
    
    if (evernoteAccount) {
        [[evernoteAccountCell_ textLabel] setText:evernoteAccount];
    }
    if (notebookName) {
        [[notebookNameCell_ textLabel] setText:notebookName];
    }
    
    NSInteger photoSizeIndex = [UserSettings sharedInstance].photoSizeIndex;
    UITableViewCell *photoSizeCell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:photoSizeIndex inSection:2]];
    [photoSizeCell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    NSLog(@"row=%d selection=%d", row, section);
    
    switch (section) {
        case 2: { // 画像サイズ
            for (NSInteger i=0; i<4; i++) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:section];
                [[tableView cellForRowAtIndexPath:ip] setAccessoryType:UITableViewCellAccessoryNone];
            }
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            [UserSettings sharedInstance].photoSizeIndex = row;
            break;
        }
        case 3: { // リセット
            switch (row) {
                case 0: { // 全登録
                    UIActionSheet *actionSheet =
                        [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SettingViewAllRegistTitle",
                                                                               @"All Regists Title for SettingView")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Cancel",
                                                                               @"Cancel")
                                      destructiveButtonTitle:NSLocalizedString(@"SettingViewAllRegistDoIt",
                                                                               @"All Regists Operation for SettingView")
                                           otherButtonTitles:nil];
                    [actionSheet setTag:0];
                    [actionSheet showInView:self.navigationController.view];
                    break;
                }
                case 1: { // 全削除
                    UIActionSheet *actionSheet =
                    [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SettingViewClearHistoryTitle",
                                                                           @"Clear History Title for SettingView")
                                                    delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"Cancel",
                                                                           @"Cancel")
                                  destructiveButtonTitle:NSLocalizedString(@"SettingViewClearHistoryDoIt",
                                                                           @"Clear History Operation for SettingView")
                                           otherButtonTitles:nil];
                    [actionSheet setTag:1];
                    [actionSheet showInView:self.navigationController.view];
                    break;
                }
            }
        }
        default: {
            break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([actionSheet tag]) {
        case 0: { // 全登録
            if (buttonIndex == 0) {
                [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                AssetsLoader *loader = [[[AssetsLoader alloc] init] autorelease];
                [loader AllRegistToStorage];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
            break;
        }
        case 1: { // 全削除
            if (buttonIndex == 0) {
                [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                AssetURLStorage *storage = [[[AssetURLStorage alloc] init] autorelease];
                [storage deleteAllURLs];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
            break;
        }
        default: {
        }
    }
}



@end
