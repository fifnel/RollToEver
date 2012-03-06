//
//  ApplicationError.m
//  RollToEver
//
//  Created by fifnel on 2012/03/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ApplicationError.h"

@implementation ApplicationError

@synthesize errorCode = errorCode_;
@synthesize errorParam = errorParam_;

- (id)initWithErrorCode:(NSInteger)code Param:(NSInteger)param;
{
    self = [super init];
    if (self) {
        errorCode_ = code;
        errorParam_ = param;
    }
    return self;
}

- (NSInteger)errorCode
{
    return errorCode_;
}

- (NSInteger)errorParam
{
    return errorParam_;
}

- (NSString *)errorString
{
    NSString *key = nil;
    
    switch (errorCode_) {
        case ERROR_UNKNOWN:
            key = @"ErrorUnknown";
            break;
        case ERROR_TRANSPORT:
            key = @"ErrorTransport";
            break;
        case ERROR_EVERNOTE:
            key = @"ErrorEvernote";
            break;
        default:
            return nil;
    }
    return NSLocalizedString(key, @"ErrorMessage");
}

- (NSString *)errorFormattedString
{
    NSString *formattedString = 
        [NSString stringWithFormat:@"%@\nCode=%d\nParam=%d\n",
         [self errorString],
         errorCode_,
         errorParam_];
    
    return formattedString;
}

@end
