//
//  ViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetsFilter.h>

@implementation ViewController

@synthesize UploadProgress = UploadProgress_;
@synthesize ProgressText = ProgressText_;
@synthesize numOfPhotos = numOfPhotos_;

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
    
    rollToEver_ = [[RollToEver alloc]init];
    rollToEver_.delegate = self;
}

- (void)viewDidUnload
{
    [self setUploadProgress:nil];
    [ProgressText_ release];
    ProgressText_ = nil;
    [self setProgressText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [rollToEver_ release];
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (IBAction)start:(id)sender {
    [rollToEver_ startUpload];
}

- (void)RollToEverStartUpload:(NSInteger)num {
    numOfPhotos_ = num;
    UploadProgress_.progress = 0.0;
    [ProgressText_ setText:@"start"];
}

- (void)RollToEverFinishUpload:(ALAsset *)assert index:(NSInteger)index {
    if (numOfPhotos_ > 0) {
        UploadProgress_.progress = (float)(index+1) / (float)numOfPhotos_;
    } else {
        UploadProgress_.progress = 1.0;
    }
    [ProgressText_ setText:[NSString stringWithFormat:@"index:%d", index]];
}

- (void)RollToEverFinishAllUpload {
    [ProgressText_ setText:@"finish"];
}

- (void)dealloc {
    [UploadProgress_ release];
    [ProgressText_ release];
    [ProgressText_ release];
    [super dealloc];
}
@end
