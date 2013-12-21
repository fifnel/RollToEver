//
//  UploadViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "UploadViewController.h"
#import "PhotoUploader.h"
#import "UserSettings.h"
#import "MBProgressHUD.h"
#import "EvernoteSDK.h"

@implementation UploadViewController {
    NSOperationQueue *_operationQueue;
    MBProgressHUD *_hud;
    
    NSMutableArray *_skipReasonMessages;
}

// Evernote転送残量表示の更新
- (void)updateEvernoteCycle
{
    [[EvernoteNoteStore noteStore] getSyncStateWithSuccess:^(EDAMSyncState *syncState) {
        __block int64_t uploaded = syncState.uploaded;
        [[EvernoteUserStore userStore] getUserWithSuccess:^(EDAMUser *user) {
            int64_t limit = user.accounting.uploadLimit;

            int64_t remain = limit - uploaded;
            float remaining_ratio = (float) remain / (float) limit;

            [self.evernoteCycleProgress setProgress:remaining_ratio];
            if (remaining_ratio < 0.1f) {
                [self.evernoteCycleProgress setProgressTintColor:[UIColor redColor]];
            } else if (remaining_ratio < 0.2f) {
                [self.evernoteCycleProgress setProgressTintColor:[UIColor yellowColor]];
            } else {
                [self.evernoteCycleProgress setProgressTintColor:[UIColor greenColor]];
            }
            NSString *text = [NSString stringWithFormat:@"%@ %lldMB",
                                                        NSLocalizedString(@"UploadingRemaining", @"Remaining for UploadView"),
                                                        remain / 1024 / 1024];
            [self.evernoteCycleLabel setText:text];


        }                                         failure:^(NSError *error) {
        }];
    }                                              failure:
                                                           ^(NSError *error) {
                                                           }];
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
    _skipReasonMessages = nil;

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([_operationQueue operationCount] == 0) {
        [self.uploadingProgress setProgress:0.0f];

        PhotoUploader *uploader = [[PhotoUploader alloc] initWithDelegate:self];
        [_operationQueue addOperation:uploader];

        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText = NSLocalizedString(@"Loading", "Now Loading");
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

    // [self dismissModalViewControllerAnimated:YES];
    // dismissModalViewControllerAnimated の呼び出しはキャンセル後のdelegateから呼ぶ
}

// アップロードのループ開始
- (void)PhotoUploaderWillStart:(PhotoUploader *)photoUploader totalCount:(NSNumber *)totalCount
{
    if ([[UserSettings sharedInstance] killIdleSleepFlag]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _hud = nil;
    _skipReasonMessages = [[NSMutableArray alloc] init];

    [self updateEvernoteCycle];
}

// アップロード開始
- (void)PhotoUploaderWillUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    [self.uploadingProgress setProgress:0.0f];
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    [self.uploadingImage setImage:[UIImage imageWithCGImage:[rep fullScreenImage]]];
    [self.uploadingCountLabel setText:[NSString stringWithFormat:@"%d / %d", [index intValue] + 1, [totalCount intValue]]];
}

// アップロード中
- (void)PhotoUploaderUploading:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount uploadedSize:(NSNumber *)uploadedSize totalSize:(NSNumber *)totalSize
{
    [self.uploadingProgress setProgress:[uploadedSize floatValue] / [totalSize floatValue]];
}

// アップロード完了
- (void)PhotoUploaderDidUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    [self.uploadingProgress setProgress:1.0f];
    [self updateEvernoteCycle];
}

// アップロードスキップ
- (void)PhotoUploaderDidSkipped:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount reasonException:(NSException *)exception
{
    [self.uploadingProgress setProgress:1.0f];
    
    NSString* message = [NSString stringWithFormat:@"%@:%@", exception.name, exception.reason];
    [_skipReasonMessages addObject:message];
}

// アップロードのループ終了
- (void)PhotoUploaderDidFinish:(PhotoUploader *)photoUploader
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    UIAlertView *alert;
    if ([_skipReasonMessages count] > 0) {
        NSString* reasonMessage = @"Upload Completed\n\n**** Skip Photo Report ****";
        for(NSString *reason in _skipReasonMessages) {
            reasonMessage = [NSString stringWithFormat:@"%@\n%@", reasonMessage, reason];
        }
        alert = [[UIAlertView alloc] initWithTitle:@"Finish" message:reasonMessage delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:@"Finish" message:@"Upload Completed" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    }
    [alert show];
}

// エラー
- (void)PhotoUploaderError:(PhotoUploader *)photoUploader error:(ApplicationError *)error
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    NSString *errorMsg = [error errorFormattedString];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}

// キャンセル
- (void)PhotoUploaderCanceled:(PhotoUploader *)photoUploader
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// アラートビューのdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
