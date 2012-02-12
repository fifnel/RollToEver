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
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "Evernote.h"
#import "UserSettings.h"

@interface ViewController()

- (void)uploadPhoto:(ALAsset *)asset;
- (void)evernoteUploadAsync;
- (void)updateUploadProgress:(NSDictionary *)params;

@end

@implementation ViewController

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
    enumerator_ = [[AssetsEnumerator alloc] init];
    enumerator_.delegate = self;
    urls_ = [[NSMutableArray alloc] init];
    assetUrlStorage_ = [[AssetURLStorage alloc] init];
}

- (void)viewDidUnload
{
    [self setUploadProgress:nil];
    [ProgressText_ release];
    ProgressText_ = nil;
    [self setProgressText:nil];
    [enumerator_ release];
    [urls_ release];
    [assetUrlStorage_ release];
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
    [self performSelectorInBackground:@selector(startUploadAsync) withObject:nil];
}

- (void)dealloc {
    [UploadProgress_ release];
    [ProgressText_ release];
    [ProgressText_ release];
    [super dealloc];
}

#pragma mark - AssetsEnumeration Delegate

- (void)startUploadAsync {
    [enumerator_ startEnumeration];
}

- (void)AssetsEnumerationStart:(NSInteger)count {
    NSLog(@"AssetsEnumerationStart:%d", count);
    [urls_ release];
    urls_ = [[NSMutableArray alloc] init];
    
    UploadProgress_.progress = 0.0;
    [ProgressText_ setText:@"enumerating"];
}

- (void)AssetsEnumerationFind:(ALAsset *)asset index:(NSInteger)index stop:(BOOL *)stop {
    if (asset == nil) {
        return;
    }
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    if (![assetUrlStorage_ isExistURL:[rep.url absoluteString]]) {
        NSLog(@"add url:%@", [rep.url absoluteString]);
        [urls_ addObject:rep.url];
    } else {
        NSLog(@"skip url:%@", [rep.url absoluteString]);
//        [urls_ addObject:rep.url];//test
    }
    
    //    *stop = YES;
}

- (void)AssetsEnumerationEnd {
    NSLog(@"AssetsEnumerationEnd count=%d", [urls_ count]);
    uploadPhotosNum_ = [urls_ count];
    uploadedPhotosNum_ = 0;
    
    NSString *msg = [NSString stringWithFormat:@"%d枚のアップロード対象画像が見つかりました。", [urls_ count]];
    UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle:@"RoolToEver" message:msg delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [alertDone show];
    [alertDone release];
    
    [self performSelectorInBackground:@selector(evernoteUploadAsync) withObject:nil];
}

- (void)AssetsEnumerationFailure:(NSError *)error {
    NSLog(@"AssetsEnumerationFailure:%@", error);
}

#pragma mark - Evernote Upload

- (void)evernoteUploadAsync {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];

    for (int i=0, end=[urls_ count]; i<end; i++) {
        [assetsLibrary assetForURL:[urls_ objectAtIndex:i] resultBlock:^(ALAsset *asset) {
            NSString *url = [[[asset defaultRepresentation] url] absoluteString];
            AssetURLStorage *urlStorage = [[AssetURLStorage alloc] init];
            if (![urlStorage isExistURL:url]) {
                [self uploadPhoto:asset];
                [urlStorage insertURL:url];
                NSLog(@"UL=%@", [urls_ objectAtIndex:i]);
            }
            [self performSelectorOnMainThread:@selector(updateUploadProgress:) withObject:nil waitUntilDone:YES];
        } failureBlock:^(NSError *error) {
            NSLog(@"failure=%@", [urls_ objectAtIndex:i]);
        }];
    }
}

- (void)updateUploadProgress:(NSDictionary *)params {
    NSLog(@"update progress");
    uploadedPhotosNum_++;
    if (uploadPhotosNum_ > 0) {
        UploadProgress_.progress = (float)(uploadedPhotosNum_) / (float)uploadPhotosNum_;
    } else {
        UploadProgress_.progress = 1.0;
    }
    [ProgressText_ setText:[NSString stringWithFormat:@"progress:%d", uploadedPhotosNum_]];

}


/**
 写真1枚のアップロード
 */
- (void)uploadPhoto:(ALAsset *)asset {
    /*
     NSLog(@"date=%@ type=%@ url=%@",
     [asset valueForProperty:ALAssetPropertyDate],
     [asset valueForProperty:ALAssetPropertyType],
     [asset valueForProperty:ALAssetPropertyURLs]
     );
     */
    // Rowデータを取得して実際のアップロード処理に投げる
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    long long size = [rep size];
    uint8_t *buf = malloc(sizeof(uint8_t)*size);
    if (buf == nil) {
        return;
    }
    NSError *error = nil;
    NSInteger readBytes = [rep getBytes:buf fromOffset:0 length:size error:&error];
    if (readBytes < 0 || error) {
        return;
    }
    NSData *data = [[NSData alloc]initWithBytesNoCopy:buf length:size];
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    
    Evernote *evernote = nil;
    @try {
        evernote = [[Evernote alloc]
                    initWithUserID:[UserSettings sharedInstance].evernoteUserId
                    Password:[UserSettings sharedInstance].evernotePassword];
        [evernote uploadPhoto:data notebookGUID:[UserSettings sharedInstance].evernoteNotebookGUID date:date filename:[rep filename]];
    }
    @catch (EDAMUserException * e) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error saving note: error code %i", [e errorCode]];
        UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle: @"Evernote" message: errorMessage delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        
        [alertDone show];
        [alertDone release];
        return;
    }
    @finally {
        [evernote release];
        free(buf);
        [data release];
    }
}


@end
