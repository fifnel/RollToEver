//
//  main.m
//  RollToEverGHUnitTest
//
//  Created by fifnel on 2012/02/12.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvernoteSDK.h"
#import "AppDelegate.h"
#import "config.h"

int main(int argc, char *argv[])
{
    int retVal = 0;
    @autoreleasepool {
        [EvernoteSession setSharedSessionHost:EVERNOTE_HOST consumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET];
        retVal = UIApplicationMain(argc, argv, nil, @"MyGHUnitIOSAppDelegate");
    }
    return retVal;
}
