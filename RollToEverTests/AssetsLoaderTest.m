//
//  AssetsLoaderTest.m
//  RollToEver
//
//  Created by fifnel on 2012/02/19.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AssetsLoaderTest.h"
#import "AssetsLoader.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@implementation AssetsLoaderTest

// All code under test must be linked into the Unit Test bundle
- (void)testAssetsLoader {
    AssetsLoader *loader = [[[AssetsLoader alloc] init] autorelease];
    
    NSLog(@"exclude start---------------------");
    NSMutableArray *urlListExclude = [loader EnumerateURLExcludeDuplication:YES];
    for (int i=0, end=[urlListExclude count]; i<end; i++) {
        NSString *url = [urlListExclude objectAtIndex:i];
        NSLog(@"url=%@", url);
        ALAsset *asset = [loader loadAssetURLString:url];
        NSLog(@"NSString size = %lld retaincount=%d", [[asset defaultRepresentation] size], [asset retainCount]);
        NSURL *urlurl = [NSURL URLWithString:url];
        ALAsset *asset2 = [loader loadAssetURL:urlurl];
        NSLog(@"NSURL size = %lld retaincount=%d", [[asset2 defaultRepresentation] size], [asset2 retainCount]);
    }
    NSLog(@"include start---------------------");
    NSArray *urlListInclude = [loader EnumerateURLExcludeDuplication:NO];
    for (id url in urlListInclude) {
        NSLog(@"url=%@", url);
        ALAsset *asset = [loader loadAssetURLString:url];
        NSLog(@"size = %lld", [[asset defaultRepresentation] size]);
    }
    NSLog(@"---------------------");
}

@end
