//
//  UploadViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/ADBannerView.h>
#import "GADBannerView.h"

@interface UploadViewController : UIViewController<ADBannerViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel         *uploadingCount;
@property (strong, nonatomic) IBOutlet UIImageView     *uploadingImage;
@property (strong, nonatomic) IBOutlet UIProgressView  *uploadingProgress;
@property (strong, nonatomic) IBOutlet UILabel         *evernoteCycleText;
@property (strong, nonatomic) IBOutlet UIProgressView  *evernoteCycleProgress;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet ADBannerView    *iadBanner;

@property (strong, nonatomic) GADBannerView *admobBanner;
@property (assign, nonatomic) BOOL enableiAd;

- (IBAction)cancel:(id)sender;

@end
