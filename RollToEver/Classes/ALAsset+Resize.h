//
//  ALAsset+Resize.h
//  RollToEver
//
//  Created by fifnel on 2013/02/04.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (Resize)

// アセット内の写真をリサイズして生データを返す
// maxPixelが0以下の場合はオリジナルサイズのまま返す
- (NSData *)resizedImageData:(NSInteger)maxPixel;

@end
