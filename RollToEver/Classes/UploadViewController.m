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
#import "ApplicationError.h"
#import "MBProgressHUD.h"

@interface UploadViewController ()

@property (retain, nonatomic, readwrite) NSOperationQueue *operationQueue;

- (void)adjustAdBanner;
- (void)updateEvernoteCycle;

@end

@implementation UploadViewController
{
    MBProgressHUD *_hud;
}

@synthesize UploadingImage;
@synthesize UploadingCount;
@synthesize UploadingProgress;
@synthesize EvernoteCycleText;
@synthesize EvernoteCycleProgress;
@synthesize adBanner;
@synthesize operationQueue;


// 広告バナー位置調整
- (void)adjustAdBanner
{
    [adBanner removeFromSuperview];
    [self.view addSubview:adBanner];
    adBanner.frame = CGRectMake(0,
                                self.view.frame.size.height - 44 - adBanner.frame.size.height,
                                self.view.frame.size.width,
                                adBanner.frame.size.height);
}

// Evernote転送残量表示の更新
- (void)updateEvernoteCycle
{
    @try {
        EvernoteUserStoreClient *userClient = [[EvernoteUserStoreClient alloc] initWithDelegate:nil];
        EDAMAccounting          *accounting = [[userClient.userStoreClient getUser:[EvernoteAuthToken sharedInstance].authToken] accounting];
        EvernoteNoteStoreClient *noteClient = [[EvernoteNoteStoreClient alloc] initWithDelegate:nil];
        EDAMSyncState           *syncStatus = [noteClient.noteStoreClient getSyncState:[EvernoteAuthToken sharedInstance].authToken];
        
        int64_t uploaded = syncStatus.uploaded;
        int64_t limit = accounting.uploadLimit;
        int64_t remain = limit - uploaded;
        float remaining_ratio = (float)remain/(float)limit;
        
        [EvernoteCycleProgress setProgress:remaining_ratio];
        if (remaining_ratio < 0.1f) {
            [EvernoteCycleProgress setProgressTintColor:[UIColor redColor]];
        } else if (remaining_ratio < 0.2f) {
            [EvernoteCycleProgress setProgressTintColor:[UIColor yellowColor]];
        } else {
            [EvernoteCycleProgress setProgressTintColor:[UIColor greenColor]];
        }
        NSString *text = [NSString stringWithFormat:@"%@ %lldMB",
                          NSLocalizedString(@"UploadingRemaining", @"Remaining for UploadView"),
                          remain/1024/1024];
        [EvernoteCycleText setText:text];
    }
    @catch (NSException *exception) {
        return;
    }
}

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
    if (_hud != nil) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        _hud = nil;
    }
}

- (void)viewDidUnload
{
    [self setUploadingCount:nil];
    [self setUploadingImage:nil];
    [self setUploadingProgress:nil];
    [self setEvernoteCycleText:nil];
    [self setEvernoteCycleProgress:nil];
    [self setOperationQueue:nil];
    [self setAdBanner:nil];
    if (_hud != nil) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        _hud = nil;
    }
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([operationQueue operationCount] == 0) {
        [UploadingProgress setProgress:0.0f];
        
        PhotoUploader *uploader = [[PhotoUploader alloc] initWithDelegate:self];
        [operationQueue addOperation:uploader];
        
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText = NSLocalizedString(@"Loading", "Now Loading");
        [self adjustAdBanner];
    }
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _hud = nil;
    [self updateEvernoteCycle];
}

// アップロード開始
- (void)PhotoUploaderWillUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    [UploadingProgress setProgress:0.0f];
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    [UploadingImage setImage:[UIImage imageWithCGImage:[rep fullScreenImage]]];
    [UploadingCount setText:[NSString stringWithFormat:@"%d / %d", [index intValue]+1, [totalCount intValue]]];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finish" message:@"Upload Completed" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}

// エラー
- (void)PhotoUploaderError:(PhotoUploader *)photoUploader error:(ApplicationError *)error
{
    NSString *errorMsg = [error errorFormattedString];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
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

@end
