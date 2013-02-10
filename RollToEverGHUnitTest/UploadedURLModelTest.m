//
//  UploadedURLModelTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/10.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "UploadedURLModel.h"
 
@interface UploadedURLModelTest : GHTestCase { }
@end
 
@implementation UploadedURLModelTest

//Method called before each tests
- (void) setUp
{
}

//Method called before after each tests
- (void) tearDown
{
}
 
- (void)testSaveAndDelete {
    NSString *url1 = @"asset://hogehoge.jpg";
    NSString *url2 = @"asset://foofoo.png";
    
    GHAssertTrue([UploadedURLModel saveUploadedURL:url1], @"save url failure");
    GHAssertTrue([UploadedURLModel isUploadedURL:url1], @"save url is not exist");
    
    [UploadedURLModel deleteAllUploadedURL];
    GHAssertFalse([UploadedURLModel isUploadedURL:url1], @"delete all urls failure");

    [UploadedURLModel saveUploadedURL:url1];
    [UploadedURLModel deleteUploadedURL:url1];
    GHAssertFalse([UploadedURLModel isUploadedURL:url1], @"delete url failure");
    
    NSArray *urlList = [NSArray arrayWithObjects:url1, url2, nil];
    GHAssertTrue([UploadedURLModel saveUploadedURLList:urlList], @"save url list failure");
    GHAssertTrue([UploadedURLModel isUploadedURL:url1] && [UploadedURLModel isUploadedURL:url2], @"save url list is not exist");
}

@end
