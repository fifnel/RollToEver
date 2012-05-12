//
//  AssetsLoader+Utils.m
//  RollToEver
//
//  Created by fifnel on 2012/02/25.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AssetsLoader+Utils.h"
#import "AssetURLStorage.h"

@implementation AssetsLoader (Utils)

- (void)AllRegisterToStorage
{
    AssetURLStorage *storage = [[AssetURLStorage alloc] init];
    NSArray *urls = [self EnumerateURLExcludeDuplication:NO];
    for (NSString *url in urls) {
        [storage insertURL:url];
    }
}

@end
