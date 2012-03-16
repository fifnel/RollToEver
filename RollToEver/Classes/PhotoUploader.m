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
{
    __weak   id              _delegate;

    __strong AssetURLStorage *_assetUrlStorage;

    __strong ALAssetsLibrary *_assetsLibrary;
    __strong ALAsset         *_currentAsset_;
             NSInteger       _currentIndex;
             NSInteger       _totalCount;
}

- (id)init
{
    self = [self initWithDelegate:nil];
    return self;
}

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self != nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        _assetUrlStorage = [[AssetURLStorage alloc] init];
        _delegate = delegate;
    }
    return self;
}

- (void)main
{
    __block AssetURLStorage *urlStorage = nil;
    
    urlStorage = [[AssetURLStorage alloc] init];
    _currentIndex = 0;
    _currentAsset_ = nil;
    _totalCount = 0;
    
    EvernoteNoteStoreClient *noteStoreClient = nil;
    
    @try {
        NSString *userid = [UserSettings sharedInstance].evernoteUserId;
        NSString *password = [UserSettings sharedInstance].evernotePassword;
        [[EvernoteAuthToken sharedInstance] connectWithUserId:userid
                                                     Password:password
                                                   ClientName:APPLICATIONNAME
                                                  ConsumerKey:CONSUMERKEY
                                               ConsumerSecret:CONSUMERSECRET];
        
        AssetsLoader *loader = [[AssetsLoader alloc] init];
        NSArray *urlList = [loader EnumerateURLExcludeDuplication:YES];
        if (urlList == nil) {
            [self PhotoUploaderErrorAsync:self error:nil];
            return;
        }
        _totalCount = [urlList count];
        [self PhotoUploaderWillStartAsync:self totalCount:[NSNumber numberWithInt:_totalCount]];
        
        noteStoreClient = [[EvernoteNoteStoreClient alloc] initWithDelegate:self];
        NSString *notebookGUID = [UserSettings sharedInstance].evernoteNotebookGUID;
        NSInteger photoSize = [UserSettings sharedInstance].photoSize;
        
        for (NSInteger i=0; i<_totalCount; i++) {
            @autoreleasepool {
                NSString *url = [urlList objectAtIndex:i];
                ALAsset *asset = [loader loadAssetURLString:url];
                if (asset == nil) {
                    [self PhotoUploaderErrorAsync:self error:nil];
                    continue;
                }
                _currentIndex = i;
                _currentAsset_ = asset;
                
                [self PhotoUploaderWillUploadAsync:self
                                             asset:asset
                                             index:[NSNumber numberWithInt:i]
                                        totalCount:[NSNumber numberWithInt:_totalCount]];
                [noteStoreClient createNoteFromAsset:asset PhotoSize:photoSize NotebookGUID:notebookGUID];
                if ([self isCancelled]) {
                    [self PhotoUploaderCancelAsync:self];
                    return;
                }
                [urlStorage insertURL:url];
                
                [self PhotoUploaderDidUploadAsync:self
                                            asset:asset
                                            index:[NSNumber numberWithInt:i]
                                       totalCount:[NSNumber numberWithInt:_totalCount]];
            }
        }
        _currentAsset_ = nil;
        [self PhotoUploaderDidFinishAsync:self];
    }
    @catch (EDAMUserException *exception) {
        NSLog(@"PhotoUploader EDAMUser exception:%@", [exception reason]);
        if ([self isCancelled]) {
            [self PhotoUploaderCancelAsync:self];
        } else {
            ApplicationError *error = [[ApplicationError alloc] initWithErrorCode:ERROR_EVERNOTE Param:[exception errorCode]];
            [self PhotoUploaderErrorAsync:self error:error];
            _currentAsset_ = nil;
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
            _currentAsset_ = nil;
        }
        return;
    }
}

#pragma mark - delegate call

- (void)PhotoUploaderWillStartAsync:(PhotoUploader *)photoUploader totalCount:(NSNumber *)totalCount
{
    if ([_delegate respondsToSelector:@selector(PhotoUploaderWillStart:totalCount:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderWillStart:totalCount:) withObjects:photoUploader, totalCount, nil];
    }
}

- (void)PhotoUploaderWillUploadAsync:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    if ([_delegate respondsToSelector:@selector(PhotoUploaderWillUpload:asset:index:totalCount:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderWillUpload:asset:index:totalCount:) withObjects:photoUploader, asset, index, totalCount, nil];
    }
}

- (void)PhotoUploaderDidUploadAsync:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount
{
    if ([_delegate respondsToSelector:@selector(PhotoUploaderDidUpload:asset:index:totalCount:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderDidUpload:asset:index:totalCount:) withObjects:photoUploader, asset, index, totalCount, nil];
    }
    
}

- (void)PhotoUploaderDidFinishAsync:(PhotoUploader *)photoUploader
{
    if ([_delegate respondsToSelector:@selector(PhotoUploaderDidFinish:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderDidFinish:) withObjects:photoUploader, nil];
    }
    
}

- (void)PhotoUploaderErrorAsync:(PhotoUploader *)photoUploader error:(ApplicationError *)error;
{
    if ([_delegate respondsToSelector:@selector(PhotoUploaderError:error:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderError:error:) withObjects:photoUploader, error, nil];
    }
}

- (void)PhotoUploaderCancelAsync:(PhotoUploader *)photoUploader
{
    if ([_delegate respondsToSelector:@selector(PhotoUploaderCanceled:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderCanceled:) withObject:photoUploader waitUntilDone:NO];
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
    
    if ([_delegate respondsToSelector:@selector(PhotoUploaderUploading:asset:index:totalCount:uploadedSize:totalSize:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderUploading:asset:index:totalCount:uploadedSize:totalSize:)
                                   withObjects:self, 
         _currentAsset_,
         [NSNumber numberWithInt:_currentIndex],
         [NSNumber numberWithInt:_totalCount],
         [NSNumber numberWithInt:totalBytesWritten],
         [NSNumber numberWithInt:totalBytesExpectedToWrite],
         nil];
    }
}

@end

