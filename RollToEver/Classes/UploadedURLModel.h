//
//  UploadedURLModel.h
//  RollToEver
//
//  Created by fifnel on 2012/02/10.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

// TODO 今の状態だとインスタンスメソッドにしている意味が無い
// クラスメソッドにするか、メンバ変数を使って効率化を模索するか、検討が必要
// TODO メソッド名の変更
// もう少し具体的な用途に即した名前にする

#import <Foundation/Foundation.h>

@interface UploadedURLModel : NSObject

- (BOOL)isExistURL:(NSString *)url;

- (BOOL)insertURL:(NSString *)url;

- (BOOL)insertURLs:(NSArray *)urlList;

- (void)deleteURL:(NSString *)url;

- (void)deleteAllURLs;

@end
