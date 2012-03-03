//
//  PhotoUploader.m
//  RollToEver
//
//  Created by fifnel on 2012/02/13.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "PhotoUploader.h"
#import "UserSettings.h"
#import "AssetsLoader.h"
#import "AssetURLStorage.h"
#import "EvernoteAuthToken.h"
#import "NSObject+InvocationUtils.h"
#import "EvernoteNoteStoreClient+ALAsset.h"
#import "id.h"

@interface PhotoUploader ()

@property (assign, readwrite, nonatomic) NSInteger currentIndex;
@property (assign, readwrite, nonatomic) NSInteger totalCount;

- (void)PhotoUploaderWillStartAsync:(PhotoUploader *)photoUploader
                         totalCount:(NSNumber *)totalCount;

- (void)PhotoUploaderWillUploadAsync:(PhotoUploader *)photoUploader
                               asset:(ALAsset *)asset
                               index:(NSNumber *)index
                          totalCount:(NSNumber *)totalCount;

- (void)PhotoUploaderDidUploadAsync:(PhotoUploader *)photoUploader
                              asset:(ALAsset *)asset
                              index:(NSNumber *)index
                         totalCount:(NSNumber *)totalCount;

- (void)PhotoUploaderDidFinishAsync:(PhotoUploader *)photoUploader;

- (void)PhotoUploaderErrorAsync:(PhotoUploader *)photoUploader
                          error:(NSError *)error;

@end


@implementation PhotoUploader

// instance valiables
ALAssetsLibrary *assetsLibrary_;
AssetURLStorage *assetUrlStorage_;
id delegate_;
ALAsset *currentAsset_;

@synthesize currentIndex = currentIndex_;
@synthesize totalCount = totalCount_;

- (id)init
{
    self = [self initWithDelegate:nil];
    return self;
}

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self != nil) {
        assetsLibrary_ = [[ALAssetsLibrary alloc] init];
        assetUrlStorage_ = [[AssetURLStorage alloc] init];
        delegate_ = delegate;
    }
    return self;
}

- (void)dealloc {
    [assetsLibrary_ release];
    [assetUrlStorage_ release];
    
    [super dealloc];
}

- (void)main
{
    __block AssetURLStorage *urlStorage = nil;

    urlStorage = [[[AssetURLStorage alloc] init] autorelease];
    currentIndex_ = 0;
    totalCount_ = 0;

    if ([EvernoteAuthToken sharedInstance].authToken == nil) {
        NSString *userid = [UserSettings sharedInstance].evernoteUserId;
        NSString *password = [UserSettings sharedInstance].evernotePassword;
        bool ret = [[EvernoteAuthToken sharedInstance] connectWithUserId:userid
                                                                Password:password
                                                              ClientName:APPLICATIONNAME
                                                             ConsumerKey:CONSUMERKEY
                                                          ConsumerSecret:CONSUMERSECRET];
        if (!ret) {
            [self PhotoUploaderErrorAsync:self error:nil];
            return;
        }
    }

    AssetsLoader *loader = [[[AssetsLoader alloc] init] autorelease];
    NSArray *urlList = [loader EnumerateURLExcludeDuplication:YES];
    if (urlList == nil) {
        [self PhotoUploaderErrorAsync:self error:nil];
        return;
    }
    totalCount_ = [urlList count];
    
    [self PhotoUploaderWillStartAsync:self totalCount:[NSNumber numberWithInt:self.totalCount]];
    
    EvernoteNoteStoreClient *noteStoreClient = [[[EvernoteNoteStoreClient alloc] initWithDelegate:self] autorelease];
    NSString *notebookGUID = [UserSettings sharedInstance].evernoteNotebookGUID;
    NSInteger photoSize = [UserSettings sharedInstance].photoSize;
    
    for (NSInteger i=0; i<totalCount_; i++) {
        
        // キャンセルチェック
        if ([self isCancelled]) {
            [self PhotoUploaderCancelAsync:self];
            return;
        }
        
        NSString *url = [urlList objectAtIndex:i];
        ALAsset *asset = [loader loadAssetURLString:url];
        if (asset == nil) {
            [self PhotoUploaderErrorAsync:self error:nil];
            continue;
        }
        currentAsset_ = asset;

        [self PhotoUploaderWillUploadAsync:self asset:asset index:[NSNumber numberWithInt:i] totalCount:[NSNumber numberWithInt:self.totalCount]];
        
        [noteStoreClient createNoteFromAsset:asset PhotoSize:photoSize NotebookGUID:notebookGUID];
        [urlStorage insertURL:url];

        [self PhotoUploaderDidUploadAsync:self asset:asset index:[NSNumber numberWithInt:i] totalCount:[NSNumber numberWithInt:self.totalCount]];
    }
    
    [self PhotoUploaderDidFinishAsync:self];
}
                            
#pragma mark - delegate call

- (void)PhotoUploaderWillStartAsync:(PhotoUploader *)photoUploader totalCount:(NSNumber *)totalCount
{
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderWillStart:totalCount:)]) {
        [delegate_ performSelectorOnMainThread:@selector(PhotoUploaderWillStart:totalCount:) withObjects:photoUploader, totalCount, nil];
    }
}

- (void)PhotoUploaderWillUploadAsync:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderWillUpload:asset:index:totalCount:)]) {
        [delegate_ performSelectorOnMainThread:@selector(PhotoUploaderWillUpload:asset:index:totalCount:) withObjects:photoUploader, asset, index, totalCount, nil];
    }
}

- (void)PhotoUploaderDidUploadAsync:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderDidUpload:asset:index:totalCount:)]) {
        [delegate_ performSelectorOnMainThread:@selector(PhotoUploaderDidUpload:asset:index:totalCount:) withObjects:photoUploader, asset, index, totalCount, nil];
    }
    
}

- (void)PhotoUploaderDidFinishAsync:(PhotoUploader *)photoUploader
{
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderDidFinish:)]) {
        [delegate_ performSelectorOnMainThread:@selector(PhotoUploaderDidFinish:) withObjects:photoUploader, nil];
    }
    
}

- (void)PhotoUploaderErrorAsync:(PhotoUploader *)photoUploader error:(NSError *)error
{
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderError:error:)]) {
        [delegate_ performSelectorOnMainThread:@selector(PhotoUploaderError:error:) withObjects:photoUploader, error, nil];
    }
}

- (void)PhotoUploaderCancelAsync:(PhotoUploader *)photoUploader
{
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderCanceled:)]) {
        [delegate_ performSelectorOnMainThread:@selector(PhotoUploaderCanceled:) withObject:photoUploader waitUntilDone:NO];
    }
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    // キャンセルチェック
    if ([self isCancelled]) {
        [connection cancel];
        [self PhotoUploaderCancelAsync:self];
        return;
    }

    if ([delegate_ respondsToSelector:@selector(PhotoUploaderUploading:asset:index:totalCount:uploadedSize:totalSize:)]) {
        [delegate_ performSelectorOnMainThread:@selector(PhotoUploaderUploading:asset:index:totalCount:uploadedSize:totalSize:) withObjects:self, 
         currentAsset_, self.currentIndex, self.totalCount, totalBytesWritten, totalBytesExpectedToWrite];
    }
}

@end

