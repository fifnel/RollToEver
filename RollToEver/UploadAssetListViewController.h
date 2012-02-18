//
//  UploadAssetListViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/18.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetsLoader.h"

@interface UploadAssetListViewController : UITableViewController
{
@private
    NSInteger section;
    NSInteger sectionItem;
    NSArray *assetsList;
    AssetsLoader *assetsLoader;
}

- (IBAction)startUpload:(id)sender;
@end
