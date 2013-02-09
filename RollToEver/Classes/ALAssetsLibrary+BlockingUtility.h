//
//  ALAssetsLibrary+BlockingUtility.h
//  RollToEver
//
//  Created by fifnel on 2013/02/06.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (BlockingUtility)

// アセットURLのリストを取得する
- (NSArray *)assetsURLList;

// 登録済みURL除外フィルタ済みアセットURLのリストを取得する
- (NSArray *)filteredAssetsURLList;

// 1アセットの読み込み
- (ALAsset *)loadAssetFromURLString:(NSString *)urlString;

// 1アセットの読み込み
- (ALAsset *)loadAssetFromURL:(NSURL *)url;

@end
