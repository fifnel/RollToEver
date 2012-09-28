//
//  EvernoteSession+Login.m
//  RollToEver
//
//  Created by fifnel on 2012/09/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteSession+Login.h"

#import "id.h"

@implementation EvernoteSession (Login)

- (BOOL)loginWithViewController:(UIViewController *)viewController
{
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST consumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET];

    __block BOOL isSucceeded = NO;

    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:viewController completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            NSLog(@"authentication failed.");
            UIAlertView *alert = [
                    [UIAlertView alloc]
                    initWithTitle :NSLocalizedString(@"AccountSettingLoginTitle", @"Evernote Login")
                          message :NSLocalizedString(@"AccountSettingLoginFailed", "Login failed")
                         delegate :nil cancelButtonTitle :@"OK"
                otherButtonTitles :nil];
            [alert show];

        } else {
            NSLog(@"authentication succeeded.");
            isSucceeded = YES;
        }
    }];

    return isSucceeded;
}

@end
