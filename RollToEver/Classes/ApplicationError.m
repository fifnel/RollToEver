//
//  ApplicationError.m
//  RollToEver
//
//  Created by fifnel on 2012/03/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ApplicationError.h"

/**
* アプリケーションエラー
*/
@implementation ApplicationError

/// エラーコード
@synthesize errorCode = errorCode_;
/// エラーパラメータ
@synthesize errorParam = errorParam_;

/// 初期化
- (id)initWithErrorCode:(NSInteger)code Param:(NSInteger)param; {
    self = [super init];
    if (self) {
        errorCode_ = code;
        errorParam_ = param;
    }
    return self;
}

/// エラーコード取得
- (NSInteger)errorCode {
    return errorCode_;
}

/// エラーパラメータ取得
- (NSInteger)errorParam {
    return errorParam_;
}

/// エラーコード取得
- (NSString *)errorString {
    NSString *key = nil;

    switch (errorCode_) {
        case ERROR_UNKNOWN:
            key = @"ErrorUnknown";
            break;
        case ERROR_TRANSPORT:
            key = @"ErrorTransport";
            break;
        case ERROR_EVERNOTE:
            key = @"ErrorEvernote";
            break;
        default:
            return nil;
    }
    return NSLocalizedString(key, @"ErrorMessage");
}

/// エラーコード文字列の生成
- (NSString *)errorFormattedString {
    NSString *formattedString =
            [NSString stringWithFormat:@"%@\nCode=%d\nParam=%d\n",
                                       [self errorString],
                                       errorCode_,
                                       errorParam_];

    return formattedString;
}

@end
