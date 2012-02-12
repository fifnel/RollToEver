//
//  RollToEver.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "RollToEver.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

#import "Evernote.h"
#import "NSString+MD5.h"
#import "NSDataMD5Additions.h"
#import "UserSettings.h"
#import "AssetURLStorage.h"

@interface RollToEver()

- (void)startUploadAsync;
- (void)uploadPhoto:(ALAsset *)asset index:(NSInteger)index;
- (void)uploadPhotoToEvernote:(NSData *)image date:(NSDate *)date filename:(NSString *)filename;

@end

@implementation RollToEver

@synthesize dateFormatter = dateFormatter_;
@synthesize evernoteTitleDateFormatter = evernoteTitleDateFormatter_;

/**
 初期化処理
 */
- (id)init {
    self = [super init];
    if (self != nil) {
        enumerator = [[AssetsEnumerator alloc] init];
        enumerator.delegate = self;
        
        dateFormatter_ = [[NSDateFormatter alloc] init];
        [dateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
        
        evernoteTitleDateFormatter_ = [[NSDateFormatter alloc] init];
        [evernoteTitleDateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return self;
}

/**
 解放処理
 */
- (void)dealloc {
    [dateFormatter_ release];
    [enumerator release];
    
    [super dealloc];
}

/**
 アップロードの開始
 */
- (void)startUpload {
    [self performSelectorInBackground:@selector(startUploadAsync) withObject:nil];
}
- (void)startUploadAsync {
    [enumerator startEnumeration];
}


- (void)AssetsEnumerationStart:(NSInteger)count {
    NSLog(@"AssetsEnumerationStart:%d", count);
}

- (void)AssetsEnumerationEnd {
    NSLog(@"AssetsEnumerationEnd");
}

- (void)AssetsEnumerationFind:(ALAsset *)asset index:(NSInteger)index {
    if (asset != nil) {
        NSString *url = [[[asset defaultRepresentation] url] absoluteString];
        AssetURLStorage *urlStorage = [[AssetURLStorage alloc] init];
        if (![urlStorage isExistURL:url]) {
            [self uploadPhoto:asset index:index];
            [urlStorage insertURL:url];
        }
    }
}

- (void)AssetsEnumerationFailure:(NSError *)error {
    NSLog(@"AssetsEnumerationFailure:%@", error);
}

/**
 写真1枚のアップロード
 */
- (void)uploadPhoto:(ALAsset *)asset index:(NSInteger)index {
    /*
    NSLog(@"index=%d date=%@ type=%@ url=%@",
          index,
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
    [self uploadPhotoToEvernote:data date:date filename:[rep filename]];
    free(buf);
    [data release];
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
    Evernote *evernote = nil;
    @try {
        evernote = [[Evernote alloc]
                    initWithUserID:[UserSettings sharedInstance].evernoteUserId
                    Password:[UserSettings sharedInstance].evernotePassword];
        [evernote createNote:note];
        [evernote release];
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
    }
}

@end
