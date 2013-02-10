//
//  UploadedURLModel.h
//  RollToEver
//
//  Created by fifnel on 2012/02/10.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

// TODO 今の状態だとインスタンスメソッドにしている意味が無い
// クラスメソッドにするか、メンバ変数を使って効率化を模索するか、検討が必要

#import <Foundation/Foundation.h>

@interface UploadedURLModel : NSObject

- (BOOL)isExistURL:(NSString *)url;

- (BOOL)saveUploadedURL:(NSString *)url;

- (BOOL)saveUploadedURLList:(NSArray *)urlList;

- (void)deleteUploadedURL:(NSString *)url;

- (void)deleteAllUploadedURL;

@end
