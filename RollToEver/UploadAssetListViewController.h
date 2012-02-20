//
//  UploadAssetListViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/18.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetsLoader.h"
#import "Evernote.h"
#import "AssetURLStorage.h"

@interface UploadAssetListViewController : UITableViewController
{
@private
    NSArray *assetsList_;
    AssetsLoader *assetsLoader_;
    NSMutableArray *assetsUploadProgress_;
    AssetURLStorage *urlStorage_;
    NSOperationQueue *operationQueue_;
    NSInteger uploadIndex_;
}

- (IBAction)startUpload:(id)sender;

@end
