//
//  ALAsset+Evernote.h
//  RollToEver
//
//  Created by fifnel on 2012/09/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "EvernoteSDK.h"

@interface ALAsset (Evernote)

// Evernoteノートの作成
- (EDAMNote *)createEDAMNote:(NSString *)notebookGUID photoSize:(NSInteger)photoSize;

// アセット内の写真をリサイズして生データを返す
// maxPixelが0以下の場合はオリジナルサイズのまま返す
- (NSData *)resizedImageData:(NSInteger)maxPixel;

// ファイル名の取得
- (NSString *)getFileName;

@end
