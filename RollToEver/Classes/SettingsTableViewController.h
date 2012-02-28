//
//  SettingsTableViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController<UIActionSheetDelegate>
{
@private
    IBOutlet UITableViewCell *evernoteAccountCell_;
    IBOutlet UITableViewCell *notebookNameCell_;
}

@end
