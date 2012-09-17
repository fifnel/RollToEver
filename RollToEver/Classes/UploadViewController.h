//
//  UploadViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/ADBannerView.h>

@interface UploadViewController : UIViewController <ADBannerViewDelegate>

@property(weak, nonatomic) IBOutlet UILabel *uploadingCountLabel;
@property(weak, nonatomic) IBOutlet UIImageView *uploadingImage;
@property(weak, nonatomic) IBOutlet UIProgressView *uploadingProgress;
@property(weak, nonatomic) IBOutlet UILabel *evernoteCycleLabel;
@property(weak, nonatomic) IBOutlet UIProgressView *evernoteCycleProgress;
@property(weak, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)cancel:(id)sender;

@end
