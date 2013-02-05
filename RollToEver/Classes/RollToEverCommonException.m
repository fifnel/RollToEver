//
//  RollToEverCommonException.m
//  RollToEver
//
//  Created by fifnel on 2013/02/06.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "RollToEverCommonException.h"

@implementation RollToEverCommonException

+ (id)exceptionWithFormatName:(NSString *)formatName
{
    return [super exceptionWithName:@"RollToEverCommonException" reason:formatName userInfo:nil];
}

@end
