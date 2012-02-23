//
//  AllAssetsURLRegister.h
//  RollToEver
//
//  Created by fifnel on 2012/02/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetsEnumerator.h"
#import "AssetURLStorage.h"

@interface AllAssetsURLRegister : NSObject
{
@private
    AssetsEnumerator *enumerator_;
    AssetURLStorage *storage_;
}

@property (retain) id delegate;
- (void)start;

@end


@interface NSObject(AllAssetsURLRegisterDelegate)

- (void)AllAssetsURLRegisterDidFinish:(BOOL)succeeded;

@end