//
//  ALAsset+TransformForEvernote.h
//  RollToEver
//
//  Created by fifnel on 2013/02/04.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (TransformForEvernote)

// 拡張子文字列をUTTypeに変換する
+ (CFStringRef)stringToUTType:(NSString *)extension;

// 拡張子文字列をMIME向け文字列に変換する
+ (NSString *)stringToMIMEType:(NSString *)extension;

// ファイル名の取得
- (NSString *)filename;

// ファイルの拡張子の取得(lowercaseに変換します)
- (NSString *)fileExtension;

// UTType(CGImage生成時のフォーマット指定)の取得
- (CFStringRef)UTType;

// MIMEタイプの取得
- (NSString *)MIMEType;

// リサイズ比率の取得
- (float)resizeRatio:(NSInteger)maxPixel;

// 回転方向の取得
- (float)orientation;

// アセット内の写真をEvernote向けに変換して生データを返す
// maxPixelが0以下の場合はオリジナルサイズのまま返す
- (NSData *)transformForEvernote:(NSInteger)maxPixel;

@end
