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

/// 初期化
- (id)initWithErrorCode:(NSInteger)code Param:(NSInteger)param; {
    self = [super init];
    if (self) {
        _errorCode = code;
        _errorParam = param;
    }
    return self;
}

/// エラーコード取得
- (NSString *)errorString {
    NSString *key = nil;

    switch (_errorCode) {
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
                                       _errorCode,
                                       _errorParam];

    return formattedString;
}

@end
