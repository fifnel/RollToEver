//
//  ViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/ADBannerView.h>
#import "GADBannerView.h"


@interface ViewController : UIViewController<ADBannerViewDelegate>

- (IBAction)refreshPhotoCount:(id)sender;

@property (strong, nonatomic, readonly) IBOutlet UILabel *photoCountInfo;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet ADBannerView *adBanner;

@property (assign, nonatomic, readonly) NSInteger photoCount;
@property (assign, nonatomic) BOOL skipUpdatePhotoCount;
@property (assign, nonatomic) BOOL enableiAd;

@property (strong, nonatomic) GADBannerView *admobBanner;

@end
