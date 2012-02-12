//
//  UploadViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/12.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetsEnumerator.h"
#import "AssetURLStorage.h"

@interface UploadViewController : UIViewController
{
@private
    AssetsEnumerator *enumerator_;
    NSMutableArray *urls_;
    AssetURLStorage *assetUrlStorage_;
}

@end
