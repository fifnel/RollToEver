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
{
    __strong UploadedURLModel *model;
}

//Method called before each tests
- (void) setUp
{
    model = [[UploadedURLModel alloc] init];
}

//Method called before after each tests
- (void) tearDown
{
    
} 
 
- (void)testSaveAndDelete {
    NSString *url1 = @"asset://hogehoge.jpg";
    NSString *url2 = @"asset://foofoo.png";
    
    GHAssertTrue([model insertURL:url1], @"save url failure");
    GHAssertTrue([model isExistURL:url1], @"save url is not exist");
    
    [model deleteAllURLs];
    GHAssertFalse([model isExistURL:url1], @"delete all urls failure");
    
    [model insertURL:url1];
    [model deleteURL:url1];
    GHAssertFalse([model isExistURL:url1], @"delete url failure");
    
    NSArray *urlList = [NSArray arrayWithObjects:url1, url2, nil];
    GHAssertTrue([model insertURLs:urlList], @"save url list failure");
    GHAssertTrue([model isExistURL:url1] && [model isExistURL:url2], @"save url list is not exist");
}

@end
