//
//  AllAssetsURLRegister.m
//  RollToEver
//
//  Created by fifnel on 2012/02/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AllAssetsURLRegister.h"
#import <AssetsLibrary/ALAssetRepresentation.h>

@implementation AllAssetsURLRegister

@synthesize delegate = delegate_;

- (id)init {
    self = [super init];
    if (self) {
        enumerator_ = [[AssetsEnumerator alloc] init];
        enumerator_.delegate = self;
        storage_ = [[AssetURLStorage alloc] init];
    }
    return self;
}

- (void)dealloc {
    [storage_ release];
    [enumerator_ release];
}

- (void)start {
    [enumerator_ startEnumeration];
}

- (void)AssetsEnumerationFind:(ALAsset *)asset index:(NSInteger)index stop:(BOOL *)stop {
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSString *url = [rep.url absoluteString];
    NSLog(@"insert:%@", url);
    [storage_ insertURL:url];
}

- (void)AssetsEnumerationEnd {
    if ([delegate_ respondsToSelector:@selector(AllAssetsURLRegisterDidFinish:)]) {
        [delegate_ AllAssetsURLRegisterDidFinish:YES];
    }
}

- (void)AssetsEnumerationFailure:(NSError *)error {
    if ([delegate_ respondsToSelector:@selector(AllAssetsURLRegisterDidFinish:)]) {
        [delegate_ AllAssetsURLRegisterDidFinish:NO];
    }
}


@end
