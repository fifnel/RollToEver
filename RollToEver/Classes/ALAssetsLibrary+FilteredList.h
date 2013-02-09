//
//  ALAssetsLibrary+FilteredList.h
//  RollToEver
//
//  Created by fifnel on 2013/02/10.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (FilteredList)

// 登録済みURL除外フィルタ済みアセットURLのリストを取得する
- (NSArray *)filteredAssetsURLList;

@end
