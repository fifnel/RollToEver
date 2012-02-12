//
//  ViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetsEnumerator.h"
#import "AssetURLStorage.h"

@interface ViewController : UIViewController
{
@private
    AssetsEnumerator *enumerator_;
    NSMutableArray *urls_;
    AssetURLStorage *assetUrlStorage_;

    NSInteger uploadPhotosNum_;
    NSInteger uploadedPhotosNum_;
}

- (IBAction)start:(id)sender;

@property (retain, nonatomic) IBOutlet UIProgressView *UploadProgress;
@property (retain, nonatomic) IBOutlet UILabel *ProgressText;

@end
