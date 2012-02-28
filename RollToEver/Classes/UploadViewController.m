//
//  UploadViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "UploadViewController.h"
#import "PhotoUploader.h"
#import "EvernoteAuthToken.h"
#import "EvernoteUserStoreClient.h"
#import "EvernoteNoteStoreClient.h"
#import "EvernoteNoteStoreClient+ALAsset.h"

@interface UploadViewController ()

@property (retain, nonatomic, readwrite) NSOperationQueue *operationQueue;

- (void)updateEvernoteCycle;

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

- (void)viewWillAppear:(BOOL)animated
{
    [UploadingProgress setProgress:0.0f];
    
    PhotoUploader *uploader = [[PhotoUploader alloc] initWithDelegate:self];
    [operationQueue addOperation:uploader];
    [uploader release];

    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [UploadingText release];
    [UploadingImage release];
    [UploadingProgress release];
    [EvernoteCycleText release];
    [EvernoteCycleProgress release];
    [operationQueue release];
    [super dealloc];
}

// キャンセルボタン
- (IBAction)cancel:(id)sender
{
    [operationQueue cancelAllOperations];

    // dismissModalViewControllerAnimated の呼び出しはキャンセル後のdelegateから呼ぶ
}

// アップロードのループ開始
- (void)PhotoUploaderWillStart:(PhotoUploader *)photoUploader totalCount:(NSNumber *)totalCount
{
    [self updateEvernoteCycle];
}

// アップロード開始
- (void)PhotoUploaderWillUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    [UploadingProgress setProgress:0.0f];
    [UploadingImage setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    [UploadingText setText:[NSString stringWithFormat:@"%d / %d", [index intValue]+1, [totalCount intValue]]];
}

// アップロード中
- (void)PhotoUploaderUploading:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount uploadedSize:(NSNumber *)uploadedSize totalSize:(NSNumber *)totalSize
{
    [UploadingProgress setProgress:[uploadedSize floatValue]/[totalSize floatValue]];
}

// アップロード完了
- (void)PhotoUploaderDidUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    [UploadingProgress setProgress:1.0f];
    [self updateEvernoteCycle];
}

// アップロードのループ終了
- (void)PhotoUploaderDidFinish:(PhotoUploader *)photoUploader
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Finish" message:@"Upload Completed" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease];
    [alert show];
}

// エラー
- (void)PhotoUploaderError:(PhotoUploader *)photoUploader error:(NSError *)error
{
    NSString *errorMsg = [NSString stringWithFormat:@"UploadError\nTransport=%d\nCode=%d",
                          [EvernoteAuthToken sharedInstance].transportError,
                          [EvernoteAuthToken sharedInstance].edamErrorCode];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease];
    [alert show];
}

// キャンセル
- (void)PhotoUploaderCanceled:(PhotoUploader *)photoUploader
{
    [self dismissModalViewControllerAnimated:YES];
}

// アラートビューのdelegate
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissModalViewControllerAnimated:YES];
}

// Evernote転送残量表示の更新
- (void)updateEvernoteCycle
{
    EvernoteUserStoreClient *userClient = [[EvernoteUserStoreClient alloc] initWithDelegate:nil];
    EDAMAccounting *accounting = [[userClient.userStoreClient getUser:[EvernoteAuthToken sharedInstance].authToken] accounting];
    EvernoteNoteStoreClient *noteClient = [[EvernoteNoteStoreClient alloc] initWithDelegate:nil];
    EDAMSyncState *syncStatus = [noteClient.noteStoreClient getSyncState:[EvernoteAuthToken sharedInstance].authToken];
    [EvernoteCycleProgress setProgress:(float)syncStatus.uploaded/(float)accounting.uploadLimit];
    NSString *text = [NSString stringWithFormat:@"%lldKiB / %lldKiB", syncStatus.uploaded/1024, accounting.uploadLimit/1024];
    [EvernoteCycleText setText:text];
}

@end
