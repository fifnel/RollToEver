//
//  ViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize UploadSingleProgress = UploadSingleProgress_;
@synthesize uploadingImage;
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
    
    operationQueue_ = [[NSOperationQueue alloc] init];
}

- (void)viewDidUnload
{
    [self setUploadProgress:nil];
    [ProgressText_ release];
    ProgressText_ = nil;
    [self setProgressText:nil];
    [self setUploadSingleProgress:nil];
    [self setUploadingImage:nil];

    [operationQueue_ release];
    
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
    PhotoUploader *uploader = [[PhotoUploader alloc] initWithDelegate:self];
    [operationQueue_ addOperation:uploader];
}

- (void)dealloc {
    [UploadProgress_ release];
    [ProgressText_ release];
    [UploadSingleProgress_ release];
    [uploadingImage release];
    [super dealloc];
}

#pragma mark - PhotoUploader delegate
- (void)PhotoUploaderWillStart:(PhotoUploader *)photoUploader totalCount:(NSInteger)totalCount {
    [ProgressText_ setText:@"start"];
}

- (void)PhotoUploaderWillUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSInteger)index totalCount:(NSInteger)totalCount {
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    UIImage *image = [[UIImage alloc] initWithCGImage:[rep fullScreenImage]];
    [uploadingImage setImage:image];
    [image release];
}

- (void)PhotoUploaderUploading:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSInteger)index totalCount:(NSInteger)totalCount uploadedSize:(NSInteger)uploadedSize totalSize:(NSInteger)totalSize {
    if (totalSize > 0) {
        [UploadProgress_ setProgress:(float)uploadedSize/(float)totalSize];
    }
}

- (void)PhotoUploaderDidUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSInteger)index totalCount:(NSInteger)totalCount {
    
}

- (void)PhotoUploaderDidFinish:(PhotoUploader *)photoUploader {
    [ProgressText_ setText:@"finish"];
}

- (void)PhotoUploaderError:(PhotoUploader *)photoUploader error:(NSError *)error {
    [ProgressText_ setText:@"error"];
}


#pragma mark - AssetsEnumeration Delegate あとでけす
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

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    [UploadSingleProgress_ setProgress:(float)totalBytesWritten/(float)totalBytesExpectedToWrite];
}

- (IBAction)goUploadList:(id)sender {
}

@end
