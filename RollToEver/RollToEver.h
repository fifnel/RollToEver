//
//  RollToEver.h
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetsEnumerator.h"

/**
 カメラロールからEvernoteへアップロードするクラス
 */
@interface RollToEver : NSObject
{
@private
    AssetsEnumerator *enumerator;
}

@property (retain) NSDateFormatter *dateFormatter;
@property (retain) NSDateFormatter *evernoteTitleDateFormatter;

- (void)startUpload;

@end
