//
//  RollToEverCommonException.h
//  RollToEver
//
//  Created by fifnel on 2013/02/06.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RollToEverCommonException : NSException

+ (id)exceptionWithFormatName:(NSString *)formatName;

@end
