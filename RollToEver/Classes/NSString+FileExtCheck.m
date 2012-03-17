//
//  NSString+FileExtCheck.m
//  RollToEver
//
//  Created by fifnel on 2012/03/17.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "NSString+FileExtCheck.h"

@implementation NSString (FileExtCheck)

/**
 拡張子のチェック
 拡張子は「.jpg」のようにドットを含める
 */
- (BOOL)hasExtension:(NSString *)ext
{
    NSInteger extLength = [ext length];
    if (ext==nil || [self length] < extLength) {
        return NO;
    }
    NSRange range = NSMakeRange([self length]-extLength, extLength);
    NSComparisonResult ret = [self compare:ext options:NSCaseInsensitiveSearch range:range];
    
    if (ret == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

@end
