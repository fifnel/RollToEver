//
//  SettingsTableViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "SettingsTableViewController.h"

#import "MainViewController.h"
#import "UserSettings.h"
#import "ALAssetsLibrary+FilteredList.h"
#import "UploadedURLModel.h"

#import "UploadedURLModel.h"
#import "MBProgressHUD.h"
#import "EvernoteSDK.h"
#import "EvernoteSession+Login.h"

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
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

    if ([[EvernoteSession sharedSession] isAuthenticated]) {
        self.evernoteLinkCell.textLabel.text = @"Logout";
    } else {
        self.evernoteLinkCell.textLabel.text = @"Login";
    }

    NSString *notebookName = [UserSettings sharedInstance].evernoteNotebookName;
    if (notebookName) {
        [[self.notebookNameCell textLabel] setText:notebookName];
    }

    NSInteger photoSizeIndex = [UserSettings sharedInstance].photoSizeIndex;
    UITableViewCell *photoSizeCell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:photoSizeIndex inSection:2]];
    [photoSizeCell setAccessoryType:UITableViewCellAccessoryCheckmark];

    BOOL killIdleSleepFlag = [UserSettings sharedInstance].killIdleSleepFlag;
    self.killIdleSleepSwitch.on = killIdleSleepFlag;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setParentSkipUpdatePhotoCount:YES];
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
        case 0: { // Evernoteログイン・ログアウト
            if ([[EvernoteSession sharedSession] isAuthenticated]) {
                self.evernoteLinkCell.textLabel.text = @"Login";
                [[EvernoteSession sharedSession] logout];
            } else {
                if ([EvernoteSession loginWithViewController:self]) {
                    self.evernoteLinkCell.textLabel.text = @"Logout";
                }
            }
            break;
        }
        case 2: { // 画像サイズ
            for (NSInteger i = 0; i < 4; i++) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:section];
                [[tableView cellForRowAtIndexPath:ip] setAccessoryType:UITableViewCellAccessoryNone];
            }
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            [UserSettings sharedInstance].photoSizeIndex = row;
            break;
        }
        case 4: { // リセット
            switch (row) {
                case 0: { // 全登録
                    UIActionSheet *actionSheet;
                    actionSheet = [[UIActionSheet alloc]
                            initWithTitle:NSLocalizedString(@"SettingViewAllRegistTitle", @"All Regists Title for SettingView") delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"SettingViewAllRegistDoIt", @"All Regists Operation for SettingView") otherButtonTitles:nil];
                    [actionSheet setTag:0];
                    [actionSheet showInView:self.navigationController.view];
                    break;
                }
                case 1: { // 全削除
                    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                            initWithTitle:NSLocalizedString(@"SettingViewClearHistoryTitle", @"Clear History Title for SettingView") delegate:self
                            cancelButtonTitle:NSLocalizedString(@"Cancel",
                            @"Cancel") destructiveButtonTitle:NSLocalizedString(@"SettingViewClearHistoryDoIt", @"Clear History Operation for SettingView") otherButtonTitles:nil];
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
                
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                [UploadedURLModel saveUploadedURLList:[assetsLibrary filteredAssetsURLList]];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [self setParentSkipUpdatePhotoCount:NO];
            }
            break;
        }
        case 1: { // 全削除
            if (buttonIndex == 0) {
                [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [UploadedURLModel deleteAllUploadedURL];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [self setParentSkipUpdatePhotoCount:NO];

            }
            break;
        }
        default: {
        }
    }
}

- (void)setParentSkipUpdatePhotoCount:(BOOL)flag
{
    NSInteger parentIndex = [self.navigationController.viewControllers count] - 2;
    MainViewController *parentViewController = [self.navigationController.viewControllers objectAtIndex:parentIndex];
    parentViewController.skipUpdatePhotoCount = flag;
}

- (IBAction)changeKillIdleSleepSwitchValue:(id)sender
{
    [[UserSettings sharedInstance] setKillIdleSleepFlag:self.killIdleSleepSwitch.on];
}

@end
