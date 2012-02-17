//
//  ViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ViewController.h"
#import "THTTPAsyncClient.h"

@implementation ViewController

@synthesize UploadSingleProgress = UploadSingleProgress_;
@synthesize UploadProgress = UploadProgress_;
@synthesize ProgressText = ProgressText_;

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
    
    photoUploader_ = [[PhotoUploader alloc] init];
    photoUploader_.delegate = self;
}

- (void)viewDidUnload
{
    [self setUploadProgress:nil];
    [ProgressText_ release];
    ProgressText_ = nil;
    [self setProgressText:nil];
    [photoUploader_ release];
    [self setUploadSingleProgress:nil];
    [super viewDidUnload];
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
    [photoUploader_ start];
}

- (void)dealloc {
    [UploadProgress_ release];
    [ProgressText_ release];
    [UploadSingleProgress_ release];
    [super dealloc];
}

#pragma mark - AssetsEnumeration Delegate
- (void)PhotoUploaderReady:(NSInteger)totalCount cancel:(BOOL *)cancel {
    UploadProgress_.progress = 0.0;
    [ProgressText_ setText:@"ready"];
    
    NSString *msg = [NSString stringWithFormat:@"%d枚のアップロード対象画像が見つかりました。", totalCount];
    NSLog(@"%@", msg);
    /*
    UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle:@"RoolToEver" message:msg delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [alertDone show];
    [alertDone release];
     */
}

- (void)PhotoUploaderUploadBegin:(ALAsset *)asset count:(NSInteger)count totalCount:(NSInteger)totalCount {
    [ProgressText_ setText:[NSString stringWithFormat:@"begin:%d/%d", count, totalCount]];
}

- (void)PhotoUploaderUploadEnd:(ALAsset *)asset count:(NSInteger)count totalCount:(NSInteger)totalCount {
    [ProgressText_ setText:[NSString stringWithFormat:@"end:%d/%d", count, totalCount]];
    
    if (totalCount > 0) {
        UploadProgress_.progress = (float)count / (float)totalCount;
    } else {
        UploadProgress_.progress = 1.0;
    }
}

- (void)PhotoUploaderSucceeded {
    [ProgressText_ setText:@"succeeded"];
    
}

- (void)PhotoUploaderCenceled {
    [ProgressText_ setText:@"canceled"];
    
}

- (void)PhotoUploaderFailure {
    [ProgressText_ setText:@"failure"];
}

- (void)testRemainAsync:(NSInteger)remain sended:(NSInteger)sended total:(NSInteger)total {
    NSLog(@"testReamin:%d/%d/%d", remain, sended, total);
    [UploadSingleProgress_ setProgress:(float)sended/(float)total];
}

@end
