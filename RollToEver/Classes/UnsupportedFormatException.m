//
//  UnsupportedFormatException.m
//  RollToEver
//
//  Created by fifnel on 2012/10/28.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "UnsupportedFormatException.h"

@implementation UnsupportedFormatException

+ (id) exceptionWithFormatName: (NSString *)formatName
{
    return [super exceptionWithName:@"UnsupportedFormatException" reason:formatName userInfo:nil];
}

@end
