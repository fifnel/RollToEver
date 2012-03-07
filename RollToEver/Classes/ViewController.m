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

@end

@implementation ViewController
@synthesize uploadButton;

@synthesize photoCount = photoCount_;
@synthesize photoCountInfo = photoCountInfo_;
@synthesize skipUpdatePhotoCount = skipUpdatePhotoCount_;

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
}

- (void)viewDidUnload
{
    [self setUploadButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!skipUpdatePhotoCount_) {
        [uploadButton setEnabled:NO];
        [self updatePhotoCount];
    } else {
        [self assetsCountDidFinish];
    }
    skipUpdatePhotoCount_ = NO;

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
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
    [super dealloc];
}


- (IBAction)refreshPhotoCount:(id)sender {
    [self updatePhotoCount];
}

- (void)updatePhotoCount
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = NSLocalizedString(@"Loading", "Now Loading");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AssetsLoader *assetsLoader = [[AssetsLoader alloc] init];
        NSArray *assets = [assetsLoader EnumerateURLExcludeDuplication:YES];
        photoCount_ = [assets count];
        [assetsLoader release];
        
        [self performSelectorOnMainThread:@selector(assetsCountDidFinish) withObject:nil waitUntilDone:YES];
    });
}

- (void)assetsCountDidFinish {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (photoCount_ > 0) {
        NSString *photoCountStr = [NSString stringWithFormat:NSLocalizedString(@"MainViewPhotoCount", @"Photo Count for MainView"), photoCount_];
        photoCountInfo_.text = photoCountStr;
        [uploadButton setEnabled:YES];
    } else {
        photoCountInfo_.text = NSLocalizedString(@"MainViewPhotoNotFound", @"Photo Not Found for MainView");
        [uploadButton setEnabled:NO];
    }
}

@end
