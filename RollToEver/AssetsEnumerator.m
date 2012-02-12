//
//  AssetsEnumerator.m
//  RollToEver
//
//  Created by fifnel on 2012/02/10.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AssetsEnumerator.h"

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetsFilter.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface AssetsEnumerator()

- (void)AssetsEnumerationStartOnMainThread:(NSDictionary *)params;
- (void)AssetsEnumerationEndOnMainThread:(NSDictionary *)params;
- (void)AssetsEnumerationFindOnMainThread:(NSDictionary *)params;
- (void)AssetsEnumerationFailureOnMainThread:(NSDictionary *)params;

@end

@implementation AssetsEnumerator

@synthesize assetsLibrary = assetsLibrary_;
@synthesize delegate = delegate_;

- (id)init {
    self = [super init];
    if (self != nil) {
        assetsLibrary_ = [[ALAssetsLibrary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [assetsLibrary_ release];
    assetsLibrary_ = nil;
}

- (void) startEnumeration {
    // グループ内画像1枚ずつ呼び出される
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock =
    ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            NSNumber *num = [NSNumber numberWithInt:index];
            NSValue *stopPtr = [NSValue valueWithPointer:stop];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    result, @"asset", 
                                    num, @"index",
                                    stopPtr, @"stop",
                                    nil];
            [self performSelectorOnMainThread:@selector(AssetsEnumerationFindOnMainThread:) withObject:params waitUntilDone:YES];
        }
    };
    
    // グループごと呼び出される
    ALAssetsLibraryGroupsEnumerationResultsBlock usingBlock =
    ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NSNumber *num = [[[NSNumber alloc]initWithInteger:[group numberOfAssets]] autorelease];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    num, @"num",
                                    nil];
            [self performSelectorOnMainThread:@selector(AssetsEnumerationStartOnMainThread:)
                                   withObject:params
                                waitUntilDone:YES];
            NSLog(@"enumeration start numberOfAssets:%d", [group numberOfAssets]);
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        } else {
            NSLog(@"enumeration finish");
            [self performSelectorOnMainThread:@selector(AssetsEnumerationEndOnMainThread:)
                                   withObject:nil
                                waitUntilDone:YES];
        }
    };
    
    // 列挙に失敗したときに呼び出される
    ALAssetsLibraryAccessFailureBlock failureBlock = 
    ^(NSError *error) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil];
        [self AssetsEnumerationFailureOnMainThread:params];
    };

    // 列挙開始
    [assetsLibrary_ enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                  usingBlock:usingBlock
                                failureBlock:failureBlock];

}

- (void)AssetsEnumerationStartOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(AssetsEnumerationStart:)]) {
        NSNumber *num = [params objectForKey:@"num"];
        [delegate_ AssetsEnumerationStart:[num intValue]];
    }
}

- (void)AssetsEnumerationEndOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(AssetsEnumerationEnd)]) {
        [delegate_ AssetsEnumerationEnd];
    }
}

- (void)AssetsEnumerationFindOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(AssetsEnumerationFind:index:stop:)]) {
        NSNumber *index = [params objectForKey:@"index"];
        ALAsset *asset = [params objectForKey:@"asset"];
        NSValue *stopPtr = [params objectForKey:@"stop"];
        BOOL *stop;
        [stopPtr getValue:&stop];
        [delegate_ AssetsEnumerationFind:asset index:[index intValue] stop:stop];
    }
}

- (void)AssetsEnumerationFailureOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(AssetsEnumerationFailure:)]) {
        NSError *error = [params objectForKey:@"error"];
        [delegate_ AssetsEnumerationFailure:error];
    }
}


@end
