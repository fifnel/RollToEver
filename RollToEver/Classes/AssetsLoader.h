//
//  AssetsLoader.h
//  RollToEver
//
//  Created by fifnel on 2012/02/18.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetsFilter.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface AssetsLoader : NSObject

- (NSArray *)EnumerateURLExcludeDuplication:(BOOL)exclude;

- (ALAsset *)loadAssetURLString:(NSString *)urlString;

- (ALAsset *)loadAssetURL:(NSURL *)url;

@end
