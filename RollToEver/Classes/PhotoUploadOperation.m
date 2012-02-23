//
//  PhotoUploadOperation.m
//  RollToEver
//
//  Created by fifnel on 2012/02/19.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "PhotoUploadOperation.h"
#import "UserSettings.h"

@interface PhotoUploadOperation()
- (void)uploadPhotoToEvernote:(ALAsset *)asset;
@end

@implementation PhotoUploadOperation

@synthesize delegate = delegate_;

- (id)initWithAsset:(ALAsset *)asset {
    self = [super init];
    if (self != nil) {
        asset_ = [asset retain];
    }
    return self;
}

- (void)dealloc {
    [asset_ release];
    [super dealloc];
}

- (void)main {
    NSLog(@"operation start");
 
    if ([delegate_ respondsToSelector:@selector(PhotoUploadOperationStart:)]) {
        [delegate_ PhotoUploadOperationStart:self];
    }
    
    [self uploadPhotoToEvernote:asset_];

    if ([delegate_ respondsToSelector:@selector(PhotoUploadOperationFinish:)]) {
        [delegate_ PhotoUploadOperationFinish:self];
    }
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
        evernote.delegate = self;
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

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if ([delegate_ respondsToSelector:@selector(PhotoUploadOperation:progress:max:)]) {
        [delegate_ PhotoUploadOperation:self progress:totalBytesWritten max:totalBytesExpectedToWrite];
    }
}

@end
