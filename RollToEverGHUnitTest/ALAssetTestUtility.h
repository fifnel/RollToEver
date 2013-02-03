//
//  ALAssetTestUtility.h
//  RollToEver
//
//  Created by fifnel on 2013/02/03.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetsFilter.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface ALAssetTestUtility : NSObject

- (ALAsset *)getFirstAssertByExtension:(NSString *)ext;

@end
