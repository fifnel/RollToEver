//
//  ALAssetsLibrary+BlockingUtility.h
//  RollToEver
//
//  Created by fifnel on 2013/02/06.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (BlockingUtility)

- (NSArray *)EnumerateURLExcludeDuplication:(BOOL)exclude;

- (ALAsset *)loadAssetURLString:(NSString *)urlString;

- (ALAsset *)loadAssetURL:(NSURL *)url;

@end
