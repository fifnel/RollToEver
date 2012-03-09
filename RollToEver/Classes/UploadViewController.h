//
//  UploadViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/ADBannerView.h>

@interface UploadViewController : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *UploadingCount;
@property (retain, nonatomic) IBOutlet UIImageView *UploadingImage;
@property (retain, nonatomic) IBOutlet UIProgressView *UploadingProgress;

@property (retain, nonatomic) IBOutlet UILabel *EvernoteCycleText;
@property (retain, nonatomic) IBOutlet UIProgressView *EvernoteCycleProgress;
@property (retain, nonatomic) IBOutlet ADBannerView *adBanner;

- (IBAction)cancel:(id)sender;

@end
