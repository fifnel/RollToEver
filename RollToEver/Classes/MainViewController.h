//
//  MainViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/ADBannerView.h>

@interface MainViewController : UIViewController<ADBannerViewDelegate>

- (IBAction)refreshPhotoCount:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *photoCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *testModeButton;

@property (assign, nonatomic, readonly) NSInteger photoCount;
@property (assign, nonatomic) BOOL skipUpdatePhotoCount;

@end
