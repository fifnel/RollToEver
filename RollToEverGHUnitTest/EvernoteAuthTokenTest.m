//
//  EvernoteAuthTokenTest.m
//  RollToEver
//
//  Created by fifnel on 2012/02/25.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteAuthTokenTest.h"
#import "EvernoteAuthToken.h"
#import "UserSettings.h"
#import "id.h"
#import "EvernoteUserStoreClient.h"
#import "EvernoteNoteStoreClient.h"
#import <GHUnitIOS/GHUnit.h> 

// experiment
#import "Evernote.h"

@implementation EvernoteAuthTokenTest

- (void)setUpClass {
    NSString *username = @"evtest1";
    NSString *password = @"92TWbdrZMEwEqc";
    
    //    NSString *username = [UserSettings sharedInstance].evernoteUserId;
    //    NSString *password = [UserSettings sharedInstance].evernotePassword;

    [[EvernoteAuthToken sharedInstance] connectWithUserName:username
                                                   Password:password
                                                 ClientName:APPLICATIONNAME
                                                ConsumerKey:CONSUMERKEY
                                             ConsumerSecret:CONSUMERSECRET];
}

- (void)tearDownClass {
    
}

- (void)setUp {
}

- (void)tearDown {
}

- (void)testEvernoteAuthToken {
    
    NSLog(@"1111");
    EvernoteUserStoreClient *userClient = [[EvernoteUserStoreClient alloc] initWithDelegate:nil];
    EDAMAccounting *accounting = [[userClient.userStoreClient getUser:[EvernoteAuthToken sharedInstance].authToken] accounting];
    
    NSLog(@"2222");
    EvernoteNoteStoreClient *noteClient = [[EvernoteNoteStoreClient alloc] initWithDelegate:nil];
    EDAMSyncState *syncStatus = [noteClient.noteStoreClient getSyncState:[EvernoteAuthToken sharedInstance].authToken];
    
    NSLog(@"--------%lld / %lld", syncStatus.uploaded/1024, accounting.uploadLimit/1024);
}

- (void)testEvernoteUserStore {
    EvernoteUserStoreClient *userClient = [[EvernoteUserStoreClient alloc] initWithDelegate:nil];
    EDAMAccounting *accounting = [[userClient.userStoreClient getUser:[EvernoteAuthToken sharedInstance].authToken] accounting];
    GHAssertTrue([accounting uploadLimitIsSet], @"upload limit not set");
    NSLog(@"----upload limit:%lld", [accounting uploadLimit]);
}

- (void)testEvernoteNoteStore {
    EvernoteNoteStoreClient *noteClient = [[EvernoteNoteStoreClient alloc] initWithDelegate:nil];
    EDAMSyncState *syncStatus = [noteClient.noteStoreClient getSyncState:[EvernoteAuthToken sharedInstance].authToken];
    GHAssertTrue([syncStatus uploadedIsSet], @"uploaded not set");
    NSLog(@"----uploaded:%lld", [syncStatus uploaded]);
}

- (void)testEvernote {
    NSString *username = [UserSettings sharedInstance].evernoteUserId;
    NSString *password = [UserSettings sharedInstance].evernotePassword;

    NSLog(@"evernote test");

    Evernote *evernote = [[Evernote alloc] initWithUserID:username Password:password];
    [evernote connect];
    EDAMSyncState *syncStatus = [[evernote noteStore] getSyncState:[evernote authToken]];
    GHAssertTrue([syncStatus uploadedIsSet], @"uploaded not set");
    NSLog(@"----uploaded:%lld", [syncStatus uploaded]);
}

@end
