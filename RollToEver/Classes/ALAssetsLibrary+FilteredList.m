//
//  ALAssetsLibrary+FilteredList.m
//  RollToEver
//
//  Created by fifnel on 2013/02/10.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "ALAssetsLibrary+FilteredList.h"
#import "ALAssetsLibrary+BlockingUtility.h"
#import "ALAsset+TransformForEvernote.h"
#import "AssetURLStorage.h"

@implementation ALAssetsLibrary (FilteredList)

- (NSArray *)filteredAssetsURLList
{
    AssetURLStorage *storage = [[AssetURLStorage alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        // 登録済みチェック
        if ([storage isExistURL:evaluatedObject]) {
            return NO;
        }
        
        // 対応フォーマットチェック
        NSURL *url = [NSURL URLWithString:evaluatedObject];
        NSString *ext = [[url pathExtension] lowercaseString];
        if ([ALAsset stringToUTType:ext] == nil) {
            return NO;
        }
        if ([ALAsset stringToUTType:ext] == NULL) {
            return NO;
        }
        
        return YES;
    }];
    
    NSArray *list = [self assetsURLList];
    return [list filteredArrayUsingPredicate:predicate];
}

@end
