//
//  AccountSettingViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountSettingViewController : UIViewController <UITextFieldDelegate>
{
@private
    IBOutlet UITextField *userId;
    IBOutlet UITextField *password;
}

- (IBAction)loginEvernote:(id)sender;

@end
