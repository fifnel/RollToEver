//
//  UnsupportedFormatException.h
//  RollToEver
//
//  Created by fifnel on 2012/10/28.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnsupportedFormatException : NSException

+ (id) exceptionWithFormatName: (NSString *)formatName;

@end
