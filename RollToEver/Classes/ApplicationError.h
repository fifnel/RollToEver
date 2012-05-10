//
//  ApplicationError.h
//  RollToEver
//
//  Created by fifnel on 2012/03/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* アプリケーションエラー
*/
@interface ApplicationError : NSObject

/// エラーコード
enum ERROR_CODE {
    ERROR_UNKNOWN = 1,  ///< 不明
    ERROR_TRANSPORT,    ///< 転送エラー
    ERROR_EVERNOTE,     ///< Evernote関連エラー

    ERROR_CODE_MAX      ///< エラー種最大数
};

/// エラーコード
@property(assign, nonatomic) NSInteger errorCode;
/// エラーパラメータ
@property(assign, nonatomic) NSInteger errorParam;

/// 初期化
- (id)initWithErrorCode:(NSInteger)code Param:(NSInteger)param;

/// エラーコードの取得
- (NSInteger)errorCode;

/// エラーパラメータの取得
- (NSInteger)errorParam;

/// エラーコードの取得
- (NSString *)errorString;

/// エラーコード文字列の生成
- (NSString *)errorFormattedString;

@end
