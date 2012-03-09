//
//  ViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/ADBannerView.h>

@interface ViewController : UIViewController

@property (assign, nonatomic, readonly) NSInteger photoCount;
@property (retain, nonatomic, readonly) IBOutlet UILabel *photoCountInfo;
- (IBAction)refreshPhotoCount:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *uploadButton;
@property (assign, nonatomic) BOOL skipUpdatePhotoCount;
@property (retain, nonatomic) IBOutlet ADBannerView *adBanner;


@end
