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
#import "UploadedURLModel.h"

@implementation ALAssetsLibrary (FilteredList)

// TODO 除外されたファイルとその理由をはき出した方が良いかもしれない。デバッグ的な意味で。
- (NSArray *)filteredAssetsURLList
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        // 登録済みチェック
        if ([UploadedURLModel isUploadedURL:evaluatedObject]) {
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
