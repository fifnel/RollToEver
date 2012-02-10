//
//  RollToEver.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "RollToEver.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetsFilter.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

#import "Evernote.h"
#import "NSString+MD5.h"
#import "NSDataMD5Additions.h"
#import "UserSettings.h"

@interface RollToEver()
- (void)startUploadAsync;
- (void)uploadPhoto:(ALAsset *)asset index:(NSInteger)index stop:(BOOL *)stop;
- (void)uploadPhotoToEvernote:(NSData *)image date:(NSDate *)date filename:(NSString *)filename;
- (void)RollToEverStartUploadOnMainThread:(NSDictionary *)params;
- (void)RollToEverFinishUploadOnMainThread:(NSDictionary *)params;
- (void)RollToEverFinishAllUploadOnMainThread:(NSDictionary *)params;

@end

@implementation RollToEver

@synthesize delegate = delegate_;
@synthesize assetsLibrary = assetsLibrary_;
@synthesize lastUploadDate = lastUploadDate_;
@synthesize dateFormatter = dateFormatter_;
@synthesize evernoteTitleDateFormatter = evernoteTitleDateFormatter_;

/**
 初期化処理
 */
- (id)init {
    self = [super init];
    if (self != nil) {
        assetsLibrary_ = [[ALAssetsLibrary alloc] init];
        
        dateFormatter_ = [[NSDateFormatter alloc] init];
        [dateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
        
        evernoteTitleDateFormatter_ = [[NSDateFormatter alloc] init];
        [evernoteTitleDateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        lastUploadDate_ = nil;
    }
    
    return self;
}

/**
 解放処理
 */
- (void)dealloc {
    [dateFormatter_ release];
    [assetsLibrary_ release];
    [lastUploadDate_ release];
    
    [super dealloc];
}

/**
 アップロードの開始
 */
- (void)startUpload {
    [self performSelectorInBackground:@selector(startUploadAsync) withObject:nil];
}

/**
 スレッド動作用のアップロード開始処理
 */
- (void)startUploadAsync {
    NSString *dateStr = [UserSettings sharedInstance].lastPhotoDate;
    if (dateStr == nil) {
        lastUploadDate_ = nil;
    } else {
        lastUploadDate_ = [[dateFormatter_ dateFromString:dateStr] retain];
    }
    NSLog(@"last upload=%@", lastUploadDate_);
    
    
    // グループ内画像1枚ずつ呼び出される
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock =
    ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self uploadPhoto:result index:index stop:stop];
        }
    };
    
    // グループごと呼び出される
    ALAssetsLibraryGroupsEnumerationResultsBlock usingBlock =
    ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NSNumber *num = [[[NSNumber alloc]initWithInteger:[group numberOfAssets]] autorelease];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    num, @"num",
                                    nil];
            [self performSelectorOnMainThread:@selector(RollToEverStartUploadOnMainThread:)
                                   withObject:params
                                waitUntilDone:YES];
            NSLog(@"upload start numberOfAssets:%d", [group numberOfAssets]);
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        } else {
            NSLog(@"upload finish");
            [self performSelectorOnMainThread:@selector(RollToEverFinishAllUploadOnMainThread:)
                                   withObject:nil
                                waitUntilDone:YES];
        }
    };
    
    // 列挙開始
    [assetsLibrary_ enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                  usingBlock:usingBlock
                                failureBlock:^(NSError *error) {
                                    NSLog(@"failure");
                                }];
}

/**
 写真1枚のアップロード
 */
- (void)uploadPhoto:(ALAsset *)asset index:(NSInteger)index stop:(BOOL *)stop {
    /*
    NSLog(@"index=%d date=%@ type=%@ url=%@",
          index,
          [asset valueForProperty:ALAssetPropertyDate],
          [asset valueForProperty:ALAssetPropertyType],
          [asset valueForProperty:ALAssetPropertyURLs]
          );
     */
    NSDate *photoDate = [asset valueForProperty:ALAssetPropertyDate];
    if (photoDate == nil) {
        return;
    }
    if (lastUploadDate_ != nil && [photoDate earlierDate:lastUploadDate_] == photoDate) {
//        return; // test
    }
    
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
    [self uploadPhotoToEvernote:data date:photoDate filename:[rep filename]];
    free(buf);
    [data release];
    
    // 最終アップロード日時の更新
    lastUploadDate_ = photoDate;
    NSString *dateStr = [dateFormatter_ stringFromDate:lastUploadDate_];
    [UserSettings sharedInstance].lastPhotoDate = dateStr;
    
    NSNumber *indexNumber = [[[NSNumber alloc] initWithInteger:index] autorelease];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            asset, @"asset",
                            indexNumber, @"index",
                            nil];
    [self performSelectorOnMainThread:@selector(RollToEverFinishUploadOnMainThread:) withObject:params waitUntilDone:YES];
}

/**
 Evernoteへ写真のアップロードをする
 */
- (void)uploadPhotoToEvernote:(NSData *)image date:(NSDate *)date filename:(NSString *)filename {
    
    NSUInteger imageSize = [image length];
    if (imageSize <= 0) {
        return;
    }

    EDAMNote *note = [[[EDAMNote alloc] init] autorelease];
    note.title = [evernoteTitleDateFormatter_ stringFromDate:date];
    // TODO アップロード先のノートブックは設定から読み込みたい
//    note.notebookGuid = [indexArray objectAtIndex:[notebookPicker selectedRowInComponent:0]];  
    
    // Calculating the md5
    NSString *hash = [[[image md5] description] stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash substringWithRange:NSMakeRange(1, [hash length] - 2)];
        
    // 1) create the data EDAMData using the hash, the size and the data of the image
    EDAMData *imageData = [[[EDAMData alloc] initWithBodyHash:[hash dataUsingEncoding: NSASCIIStringEncoding] size:[image length] body:image] autorelease];

    // 2) Create an EDAMResourceAttributes object with other important attributes of the file
    EDAMResourceAttributes *imageAttributes = [[[EDAMResourceAttributes alloc] init] autorelease];
    [imageAttributes setFileName:filename];
    
    // 3) create an EDAMResource the hold the mime, the data and the attributes
    EDAMResource *imageResource  = [[[EDAMResource alloc] init] autorelease];
    [imageResource setMime:@"image/jpeg"];
    [imageResource setData:imageData];
    [imageResource setAttributes:imageAttributes];
    
    // We are quickly the ENML code for the image to the content
    NSString *ENML = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note><en-media type=\"image/jpeg\" hash=\"%@\"/></en-note>", hash];
    
    // We are transforming the resource into a array to attach it to the note
    NSArray *resources = [[NSArray alloc] initWithObjects:imageResource, nil];
    
    NSLog(@"%@", ENML);
    
    // Adding the content & resources to the note
    [note setContent:ENML];
    [note setResources:resources];
    [note setCreated:[date timeIntervalSince1970]*1000];
    
    // Saving the note on the Evernote servers
    // Simple error management
    @try {
        [[Evernote sharedInstance] createNote:note];
    }
    @catch (EDAMUserException * e) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error saving note: error code %i", [e errorCode]];
        UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle: @"Evernote" message: errorMessage delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        
        [alertDone show];
        [alertDone release];
        return;
    }
}

/**
 アップロード開始（メインスレッドから呼ばれる）
 */
- (void)RollToEverStartUploadOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(RollToEverStartUpload:)]) {
        NSNumber *num = [params objectForKey:@"num"];
        [delegate_ RollToEverStartUpload:[num integerValue]];
    }
}

/**
 1枚の画像アップロード完了（メインスレッドから呼ばれる）
 */
- (void)RollToEverFinishUploadOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(RollToEverFinishUpload:index:)]) {
        ALAsset *asset = [params objectForKey:@"asset"];
        NSNumber *index = [params objectForKey:@"index"];
        [delegate_ RollToEverFinishUpload:asset index:[index integerValue]];
    }
}

/**
 全部の画像アップロード完了（メインスレッドから呼ばれる）
 */
- (void)RollToEverFinishAllUploadOnMainThread:(NSDictionary *)params {
    if ([delegate_ respondsToSelector:@selector(RollToEverFinishAllUpload)]) {
        [delegate_ RollToEverFinishAllUpload];
    }
}

@end
