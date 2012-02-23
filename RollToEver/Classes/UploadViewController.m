//
//  UploadViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "UploadViewController.h"
#import "PhotoUploader.h"

@interface UploadViewController ()

@property (retain, nonatomic, readwrite) NSOperationQueue *operationQueue;

@end

@implementation UploadViewController

@synthesize UploadingText;
@synthesize UploadingImage;
@synthesize UploadingProgress;
@synthesize EvernoteCycleText;
@synthesize EvernoteCycleProgress;
@synthesize operationQueue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    operationQueue = [[NSOperationQueue alloc] init];
}

- (void)viewDidUnload
{
    [self setUploadingText:nil];
    [self setUploadingImage:nil];
    [self setUploadingProgress:nil];
    [self setEvernoteCycleText:nil];
    [self setEvernoteCycleProgress:nil];
    [self setOperationQueue:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [UploadingProgress setProgress:0.0f];
    
    PhotoUploader *uploader = [[PhotoUploader alloc] init];
    [operationQueue addOperation:uploader];
    [uploader release];

    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [UploadingText release];
    [UploadingImage release];
    [UploadingProgress release];
    [EvernoteCycleText release];
    [EvernoteCycleProgress release];
    [operationQueue release];
    [super dealloc];
}

- (IBAction)cancel:(id)sender {
    // アップロード処理を止める何かを入れる
    [self dismissModalViewControllerAnimated:YES];
}

- (void)PhotoUploaderWillStart:(PhotoUploader *)photoUploader totalCount:(NSNumber *)totalCount {
    
}

- (void)PhotoUploaderWillUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount {
    [UploadingProgress setProgress:0.0f];
    [UploadingImage setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
}

- (void)PhotoUploaderUploading:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount uploadedSize:(NSNumber *)uploadedSize totalSize:(NSNumber *)totalSize {
    [UploadingProgress setProgress:[uploadedSize floatValue]/[totalSize floatValue]];
}

- (void)PhotoUploaderDidUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount {
    [UploadingProgress setProgress:1.0f];
}

- (void)PhotoUploaderDidFinish:(PhotoUploader *)photoUploader {
    
}

- (void)PhotoUploaderError:(PhotoUploader *)photoUploader error:(NSError *)error {
    
}

@end
