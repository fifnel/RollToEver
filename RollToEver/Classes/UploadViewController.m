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

@synthesize uploadingImage          = _uploadingImage;
@synthesize uploadingCount          = _uploadingCount;
@synthesize uploadingProgress       = _uploadingProgress;
@synthesize evernoteCycleText       = _evernoteCycleText;
@synthesize evernoteCycleProgress   = _evernoteCycleProgress;
@synthesize toolBar                 = _toolBar;
@synthesize adBanner                = _adBanner;
@synthesize operationQueue          = _operationQueue;
@synthesize bannerIsVisible         = _bannerIsVisible;


// 広告バナー位置調整
- (void)adjustAdBanner
{
    CGFloat posY = self.view.frame.size.height;
    if (_bannerIsVisible) {
        posY -= _adBanner.frame.size.height;
    }

    [_adBanner removeFromSuperview];
    [self.view addSubview:_adBanner];
    _adBanner.frame = CGRectMake(0,
                                 posY,
                                 self.view.frame.size.width,
                                 _adBanner.frame.size.height);
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
        
        [_evernoteCycleProgress setProgress:remaining_ratio];
        if (remaining_ratio < 0.1f) {
            [_evernoteCycleProgress setProgressTintColor:[UIColor redColor]];
        } else if (remaining_ratio < 0.2f) {
            [_evernoteCycleProgress setProgressTintColor:[UIColor yellowColor]];
        } else {
            [_evernoteCycleProgress setProgressTintColor:[UIColor greenColor]];
        }
        NSString *text = [NSString stringWithFormat:@"%@ %lldMB",
                          NSLocalizedString(@"UploadingRemaining", @"Remaining for UploadView"),
                          remain/1024/1024];
        [_evernoteCycleText setText:text];
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
    _operationQueue = [[NSOperationQueue alloc] init];
    if (_hud != nil) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        _hud = nil;
    }
}

- (void)viewDidUnload
{
    if (_hud != nil) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        _hud = nil;
    }
    [self setToolBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([_operationQueue operationCount] == 0) {
        [_uploadingProgress setProgress:0.0f];
        
        PhotoUploader *uploader = [[PhotoUploader alloc] initWithDelegate:self];
        [_operationQueue addOperation:uploader];
        
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
    [_operationQueue cancelAllOperations];

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
    [_uploadingProgress setProgress:0.0f];
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    [_uploadingImage setImage:[UIImage imageWithCGImage:[rep fullScreenImage]]];
    [_uploadingCount setText:[NSString stringWithFormat:@"%d / %d", [index intValue]+1, [totalCount intValue]]];
}

// アップロード中
- (void)PhotoUploaderUploading:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount uploadedSize:(NSNumber *)uploadedSize totalSize:(NSNumber *)totalSize
{
    [_uploadingProgress setProgress:[uploadedSize floatValue]/[totalSize floatValue]];
}

// アップロード完了
- (void)PhotoUploaderDidUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    [_uploadingProgress setProgress:1.0f];
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

#pragma mark _adBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (self.bannerIsVisible) {
		// すでにロードされている
	} else    {
		// 50ドット上にずらして画面を可視にする
        [UIView beginAnimations:@"animate_adBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -_adBanner.frame.size.height);
        self.toolBar.frame = CGRectOffset(self.toolBar.frame, 0, -_adBanner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	if (self.bannerIsVisible)
	{
		// 失敗したので画面外に出す
		[UIView beginAnimations:@"animate_adBannerOff" context:NULL];
		banner.frame = CGRectOffset(banner.frame, 0, _adBanner.frame.size.height);
        self.toolBar.frame = CGRectOffset(self.toolBar.frame, 0, _adBanner.frame.size.height);
		[UIView commitAnimations];
		self.bannerIsVisible = NO;
	}
}

@end
