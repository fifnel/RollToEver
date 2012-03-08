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
#import "Errors.h"
#import "THTTPAsyncClient.h"



@interface PhotoUploader ()

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
                          error:(ApplicationError *)error;

@end


@implementation PhotoUploader

// instance valiables
ALAssetsLibrary *assetsLibrary_;
AssetURLStorage *assetUrlStorage_;
id delegate_;
ALAsset *currentAsset_;
NSInteger currentIndex_;
NSInteger totalCount_;

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
    currentAsset_ = nil;
    totalCount_ = 0;
    
    EvernoteNoteStoreClient *noteStoreClient = nil;
    
    @try {
        NSString *userid = [UserSettings sharedInstance].evernoteUserId;
        NSString *password = [UserSettings sharedInstance].evernotePassword;
        [[EvernoteAuthToken sharedInstance] connectWithUserId:userid
                                                     Password:password
                                                   ClientName:APPLICATIONNAME
                                                  ConsumerKey:CONSUMERKEY
                                               ConsumerSecret:CONSUMERSECRET];
        
        AssetsLoader *loader = [[[AssetsLoader alloc] init] autorelease];
        NSArray *urlList = [loader EnumerateURLExcludeDuplication:YES];
        if (urlList == nil) {
            [self PhotoUploaderErrorAsync:self error:nil];
            return;
        }
        totalCount_ = [urlList count];
        [self PhotoUploaderWillStartAsync:self totalCount:[NSNumber numberWithInt:totalCount_]];
        
        noteStoreClient = [[EvernoteNoteStoreClient alloc] initWithDelegate:self];
        NSString *notebookGUID = [UserSettings sharedInstance].evernoteNotebookGUID;
        NSInteger photoSize = [UserSettings sharedInstance].photoSize;
        
        for (NSInteger i=0; i<totalCount_; i++) {
            @autoreleasepool {
                NSString *url = [urlList objectAtIndex:i];
                ALAsset *asset = [loader loadAssetURLString:url];
                if (asset == nil) {
                    [self PhotoUploaderErrorAsync:self error:nil];
                    continue;
                }
                currentIndex_ = i;
                currentAsset_ = asset;
                
                [self PhotoUploaderWillUploadAsync:self
                                             asset:asset
                                             index:[NSNumber numberWithInt:i]
                                        totalCount:[NSNumber numberWithInt:totalCount_]];
                [noteStoreClient createNoteFromAsset:asset PhotoSize:photoSize NotebookGUID:notebookGUID];
                if ([self isCancelled]) {
                    [self PhotoUploaderCancelAsync:self];
                    return;
                }
                [urlStorage insertURL:url];
                
                [self PhotoUploaderDidUploadAsync:self
                                            asset:asset
                                            index:[NSNumber numberWithInt:i]
                                       totalCount:[NSNumber numberWithInt:totalCount_]];
            }
        }
        currentAsset_ = nil;
        [self PhotoUploaderDidFinishAsync:self];
    }
    @catch (EDAMUserException *exception) {
        NSLog(@"PhotoUploader EDAMUser exception:%@", [exception reason]);
        if ([self isCancelled]) {
            [self PhotoUploaderCancelAsync:self];
        } else {
            ApplicationError *error = [[ApplicationError alloc] initWithErrorCode:ERROR_EVERNOTE Param:[exception errorCode]];
            [self PhotoUploaderErrorAsync:self error:error];
            [error release];
            currentAsset_ = nil;
        }
        return;
    }
    @catch (NSException *exception) {
        NSLog(@"PhotoUploader exception:%@", [exception reason]);
        if ([self isCancelled]) {
            [self PhotoUploaderCancelAsync:self];
        } else {
            ApplicationError *error = [[ApplicationError alloc] initWithErrorCode:ERROR_TRANSPORT Param:0];
            [self PhotoUploaderErrorAsync:self error:error];
            [error release];
            currentAsset_ = nil;
        }
        return;
    }
    @finally {
        // THTTPAsyncClientを確実にReleaseさせたいので明示的に呼ぶ
        // releaseされればコネクションが残ることはないはず
        [noteStoreClient release];
    }
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

- (void)PhotoUploaderErrorAsync:(PhotoUploader *)photoUploader error:(ApplicationError *)error;
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

#pragma mark - THTTPAsyncClient delegate

- (void)connection:(NSURLConnection *)connection client:(THTTPAsyncClient *)client didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    // キャンセルチェック
    if ([self isCancelled]) {
        [client cancel];
        // delegate呼び出しは処理ループ側でやっている
        return;
    }
    
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderUploading:asset:index:totalCount:uploadedSize:totalSize:)]) {
        [delegate_ performSelectorOnMainThread:@selector(PhotoUploaderUploading:asset:index:totalCount:uploadedSize:totalSize:)
                                   withObjects:self, 
         currentAsset_,
         [NSNumber numberWithInt:currentIndex_],
         [NSNumber numberWithInt:totalCount_],
         [NSNumber numberWithInt:totalBytesWritten],
         [NSNumber numberWithInt:totalBytesExpectedToWrite],
         nil];
    }
}

@end

