//
//  Uploader.m
//  RollToEver
//
//  Created by fifnel on 2012/02/13.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "PhotoUploader.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <CoreLocation/CoreLocation.h>
#import "Evernote.h"
#import "UserSettings.h"
#import "AssetsEnumerator.h"
#import "AssetURLStorage.h"

@interface PhotoUploader()

- (void)startUploadAsync;
- (void)uploadPhotoToEvernote:(ALAsset *)asset;

- (void)PhotoUploaderReadyOnMainThread:(NSDictionary *)params;
- (void)PhotoUploaderUploadBeginOnMainThread:(NSDictionary *)params;
- (void)PhotoUploaderUploadEndOnMainThread:(NSDictionary *)params;
- (void)PhotoUploaderSucceededOnMainThread:(NSDictionary *)params;
- (void)PhotoUploaderFailureOnMainThread:(NSDictionary *)params;
- (void)PhotoUploaderCenceledOnMainThread:(NSDictionary *)params;

@end

@implementation PhotoUploader    

@synthesize delegate = delegate_;

- (id)init {
    self = [super init];
    if (self != nil) {
        assetUrlStorage_ = [[AssetURLStorage alloc] init];
        enumerator_ = [[AssetsEnumerator alloc] init];
        enumerator_.delegate = self;
        urls_ = nil;
    }
    return self;
}

- (void)start {
    // TODO すでにスレッドが動いている場合にどうするか
    // 動作中フラグみたいなのを作りたい
    [urls_ release];
    urls_ = [[NSMutableArray alloc] init];
    [self performSelectorInBackground:@selector(startUploadAsync) withObject:nil];
}

- (void)startUploadAsync {
    [enumerator_ startEnumeration];
}

- (void)AssetsEnumerationStart:(NSInteger)count {
    NSLog(@"AssetsEnumerationStart:%d", count);
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
                [urls_ addObject:rep.url];//test
    }
    //    *stop = YES;
}

- (void)AssetsEnumerationEnd {
    NSLog(@"AssetsEnumerationEnd count=%d", [urls_ count]);
    uploadPhotosNum_ = [urls_ count];
    uploadedPhotosNum_ = 0;
    
    {
        bool *cancel = NO;
        NSValue *cancelValue = [NSValue valueWithPointer:cancel];
        NSNumber *count = [NSNumber numberWithInteger:[urls_ count]];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                count, @"count",
                                cancelValue, @"cancel",
                                nil];
        [self PhotoUploaderReadyOnMainThread:params];
        if (cancel != nil && *cancel == YES) {
            [self PhotoUploaderCenceledOnMainThread:nil];
            return;
        }
    }
    
    {
        ALAssetsLibrary *assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
        for (int i=0, end=[urls_ count]; i<end; i++) {
            
            [assetsLibrary assetForURL:[urls_ objectAtIndex:i]
             
                           resultBlock:^(ALAsset *asset) {
                               NSString *url = [[[asset defaultRepresentation] url] absoluteString];
                               AssetURLStorage *urlStorage = [[[AssetURLStorage alloc] init] autorelease];
                               //                               if (![urlStorage isExistURL:url]) {
                               if (1) {
                                   NSNumber *count = [NSNumber numberWithInteger:i];
                                   NSNumber *totalCount = [NSNumber numberWithInteger:end];
                                   NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           asset, @"asset",
                                                           count, @"count",
                                                           totalCount, @"totalCount",
                                                           nil];
                                   [self PhotoUploaderUploadBeginOnMainThread:params];
                                   
                                   [self uploadPhotoToEvernote:asset];
                                   [urlStorage insertURL:url];
                                   
                                   [self PhotoUploaderUploadEndOnMainThread:params];
                                   NSLog(@"UL=%@", [urls_ objectAtIndex:i]);
                               }
                           }
             
                          failureBlock:^(NSError *error) {
                              [self PhotoUploaderFailureOnMainThread:nil];
                              NSLog(@"failure=%@", [urls_ objectAtIndex:i]);
                          }];
        }
    }
    
    [self PhotoUploaderSucceededOnMainThread:nil];
}

/**
 写真1枚のアップロード
 */
- (void)uploadPhotoToEvernote:(ALAsset *)asset {
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
//    CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
    
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
                            
#pragma mark - delegate call

- (void)PhotoUploaderReadyOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderReady:cancel:)]) {
        NSValue *cancelValue = [params objectForKey:@"cancel"];
        BOOL *cancel;
        [cancelValue getValue:&cancel];
        [delegate_ PhotoUploaderReady:[urls_ count] cancel:cancel];
    }
}
        
- (void)PhotoUploaderUploadBeginOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderUploadBegin:count:totalCount:)]) {
        ALAsset *asset = [params objectForKey:@"asset"];
        NSNumber *count = [params objectForKey:@"count"];
        NSNumber *totalCount = [params objectForKey:@"totalCount"];
        [delegate_ PhotoUploaderUploadBegin:asset count:[count intValue] totalCount:[totalCount intValue]];
    }
}

- (void)PhotoUploaderUploadEndOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderUploadEnd:count:totalCount:)]) {
        ALAsset *asset = [params objectForKey:@"asset"];
        NSNumber *count = [params objectForKey:@"count"];
        NSNumber *totalCount = [params objectForKey:@"totalCount"];
        [delegate_ PhotoUploaderUploadEnd:asset count:[count intValue] totalCount:[totalCount intValue]];
    }
}

- (void)PhotoUploaderSucceededOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderSucceeded)]) {
        [delegate_ PhotoUploaderSucceeded];
    }
}

- (void)PhotoUploaderFailureOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderFailure)]) {
        [delegate_ PhotoUploaderFailure];
    }
}

- (void)PhotoUploaderCenceledOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(PhotoUploaderCenceled)]) {
        [delegate_ PhotoUploaderCenceled];
    }
}

@end

