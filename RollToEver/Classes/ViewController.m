//
//  ViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ViewController.h"
#import "AssetsLoader.h"
#import "MBProgressHUD.h"
#import <dispatch/dispatch.h>


@interface ViewController()

@property (assign, nonatomic, readwrite) NSInteger photoCount;
@property (retain, nonatomic, readwrite) IBOutlet UILabel *photoCountInfo;

- (void)adjustAdBanner;

@end

@implementation ViewController
@synthesize uploadButton;

@synthesize photoCount = photoCount_;
@synthesize photoCountInfo = photoCountInfo_;
@synthesize skipUpdatePhotoCount = skipUpdatePhotoCount_;
@synthesize adBanner;

MBProgressHUD *hud_;

// 広告バナー位置調整
- (void)adjustAdBanner
{
    [adBanner removeFromSuperview];
    [self.navigationController.view addSubview:adBanner];
    adBanner.frame = CGRectMake(0,
                                20+44+self.view.frame.size.height - adBanner.frame.size.height,
                                self.view.frame.size.width,
                                adBanner.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    skipUpdatePhotoCount_ = NO;
    if (hud_ != nil) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        hud_ = nil;
    }
}

- (void)viewDidUnload
{
    [self setUploadButton:nil];
    [self setAdBanner:nil];
    if (hud_ != nil) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        hud_ = nil;
    }
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!hud_) {
        if (!skipUpdatePhotoCount_) {
            [uploadButton setEnabled:NO];
            [self updatePhotoCount];
        } else {
            [self assetsCountDidFinish];
        }
        skipUpdatePhotoCount_ = NO;
    } else {
        [self adjustAdBanner];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [adBanner removeFromSuperview];

}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    self.photoCountInfo = nil;

    [uploadButton release];
    [adBanner release];
    [super dealloc];
}


- (IBAction)refreshPhotoCount:(id)sender {
    [self updatePhotoCount];
}

- (void)updatePhotoCount
{
    hud_ = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud_.labelText = NSLocalizedString(@"Loading", "Now Loading");

    [self adjustAdBanner];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AssetsLoader *assetsLoader = [[AssetsLoader alloc] init];
        NSArray *assets = [assetsLoader EnumerateURLExcludeDuplication:YES];
        photoCount_ = [assets count];
        [assetsLoader release];
        
        [self performSelectorOnMainThread:@selector(assetsCountDidFinish) withObject:nil waitUntilDone:YES];
    });
}

- (void)assetsCountDidFinish {
    [self adjustAdBanner];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    hud_ = nil;

    [self adjustAdBanner];

    if (photoCount_ > 0) {
        NSString *photoCountStr = [NSString stringWithFormat:NSLocalizedString(@"MainViewPhotoCount", @"Photo Count for MainView"), photoCount_];
        photoCountInfo_.text = photoCountStr;
        [uploadButton setEnabled:YES];
    } else {
        photoCountInfo_.text = NSLocalizedString(@"MainViewPhotoNotFound", @"Photo Not Found for MainView");
        [uploadButton setEnabled:NO];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    if (hud_ == nil) {
        self.skipUpdatePhotoCount = YES;
    }
    return YES;
}

@end
