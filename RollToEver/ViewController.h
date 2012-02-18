//
//  ViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoUploader.h"

@interface ViewController : UIViewController
{
@private
    PhotoUploader *photoUploader_;
}

- (IBAction)start:(id)sender;
- (IBAction)goUploadList:(id)sender;

@property (retain, nonatomic) IBOutlet UIProgressView *UploadProgress;
@property (retain, nonatomic) IBOutlet UILabel *ProgressText;
@property (retain, nonatomic) IBOutlet UIProgressView *UploadSingleProgress;

@end
