//
//  ApplicationError.h
//  RollToEver
//
//  Created by fifnel on 2012/03/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationError : NSObject

enum ERROR_CODE {
    ERROR_UNKNOWN = 1,
    ERROR_TRANSPORT,
    ERROR_EVERNOTE,

    ERROR_CODE_MAX
};

@property (assign, nonatomic) NSInteger errorCode;
@property (assign, nonatomic) NSInteger errorParam;

- (id)initWithErrorCode:(NSInteger)code Param:(NSInteger)param;
- (NSInteger)errorCode;
- (NSInteger)errorParam;
- (NSString *)errorString;
- (NSString *)errorFormattedString;

@end
