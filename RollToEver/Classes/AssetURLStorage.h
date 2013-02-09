//
//  AssetURLStorage.h
//  RollToEver
//
//  Created by fifnel on 2012/02/10.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

// TODO クラス名を変更する
// AssetURLModel　とかの方が良い
// TODO isExistURLの処理が重くないか検討する
// 毎回取りに行くのが重くないのか
// TODO 今の状態だとインスタンスメソッドにしている意味が無い
// クラスメソッドにするか、メンバ変数を使って効率化を模索するか、検討が必要

#import <Foundation/Foundation.h>

@interface AssetURLStorage : NSObject

- (BOOL)isExistURL:(NSString *)url;

- (BOOL)insertURL:(NSString *)url;

- (BOOL)insertURLs:(NSArray *)urlList;

- (void)deleteURL:(NSString *)url;

- (void)deleteAllURLs;

- (NSArray *)filterdURLList:(NSArray *)urlList;

@end
