//
//  SettingsTableViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UIActionSheetDelegate>

@property(weak, nonatomic) IBOutlet UITableViewCell *evernoteLinkCell;
@property(weak, nonatomic) IBOutlet UITableViewCell *notebookNameCell;
@property(weak, nonatomic) IBOutlet UISwitch *killIdleSleepSwitch;

- (IBAction)changeKillIdleSleepSwitchValue:(id)sender;

@end
