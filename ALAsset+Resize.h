//
//  NSObject+ALAsset_Resize.h
//  RollToEver
//
//  Created by fifnel on 2012/02/23.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface ALAsset (Resize)

- (NSData *)resizedImageData:(NSInteger)maxPixel;

@end
