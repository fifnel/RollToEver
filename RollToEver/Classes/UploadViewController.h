//
//  UploadViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadViewController : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *UploadingCount;
@property (retain, nonatomic) IBOutlet UIImageView *UploadingImage;
@property (retain, nonatomic) IBOutlet UIProgressView *UploadingProgress;

@property (retain, nonatomic) IBOutlet UILabel *EvernoteCycleText;
@property (retain, nonatomic) IBOutlet UIProgressView *EvernoteCycleProgress;

- (IBAction)cancel:(id)sender;

@end
