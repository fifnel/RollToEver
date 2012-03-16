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

@property (strong, nonatomic) IBOutlet UILabel         *UploadingCount;
@property (strong, nonatomic) IBOutlet UIImageView     *UploadingImage;
@property (strong, nonatomic) IBOutlet UIProgressView  *UploadingProgress;
@property (strong, nonatomic) IBOutlet UILabel         *EvernoteCycleText;
@property (strong, nonatomic) IBOutlet UIProgressView  *EvernoteCycleProgress;
@property (strong, nonatomic) IBOutlet ADBannerView    *adBanner;

- (IBAction)cancel:(id)sender;

@end
