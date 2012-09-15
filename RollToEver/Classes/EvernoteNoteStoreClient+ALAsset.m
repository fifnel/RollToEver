//
//  EvernoteNoteStoreClient+ALAsset.m
//  RollToEver
//
//  Created by fifnel on 2012/02/26.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteNoteStoreClient+ALAsset.h"

#import "ALAsset+Resize.h"
#import "NSDataMD5Additions.h"
//#import "NSString+FileExtCheck.h"

@implementation EvernoteNoteStoreClient (ALAsset)

- (void)createNoteFromAsset:(ALAsset *)asset PhotoSize:(NSInteger)photoSize NotebookGUID:(NSString *)notebookGUID {
    /*
     NSLog(@"date=%@ type=%@ url=%@",
     [asset valueForProperty:ALAssetPropertyDate],
     [asset valueForProperty:ALAssetPropertyType],
     [asset valueForProperty:ALAssetPropertyURLs]
     );
     */
/*
    // ノートのタイトルのフォーマット用
    NSDateFormatter *titleDateFormatter = [[NSDateFormatter alloc] init];
    [titleDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    // Rowデータを取得して実際のアップロード処理に投げる
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSData *data = [asset resizedImageData:photoSize];
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    NSString *filename = [rep filename];

    NSString *fileType = nil;
    if ([filename hasExtension:@".jpg"]) {
        fileType = @"jpeg";
    } else if ([filename hasExtension:@".png"]) {
        fileType = @"png";
    } else {
        // 未対応フォーマット
        NSLog(@"unknown extension:%@", filename);
        return;
    }

    // データを整理してnoteを作る
    EDAMNote *note = [[EDAMNote alloc] init];
    note.title = [titleDateFormatter stringFromDate:date];
    note.notebookGuid = notebookGUID;

    // Calculating the md5
    NSString *hash = [[[data md5] description] stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash substringWithRange:NSMakeRange(1, [hash length] - 2)];

    // 1) create the data EDAMData using the hash, the size and the data of the image
    EDAMData *imageData = [[EDAMData alloc] initWithBodyHash:[hash dataUsingEncoding:NSASCIIStringEncoding] size:[data length] body:data];

    // 2) Create an EDAMResourceAttributes object with other important attributes of the file
    EDAMResourceAttributes *imageAttributes = [[EDAMResourceAttributes alloc] init];
    [imageAttributes setFileName:filename];

    // 3) create an EDAMResource the hold the mime, the data and the attributes
    EDAMResource *imageResource = [[EDAMResource alloc] init];
    [imageResource setMime:[NSString stringWithFormat:@"image/%@", fileType]];
    [imageResource setData:imageData];
    [imageResource setAttributes:imageAttributes];

    // We are transforming the resource into a array to attach it to the note
    NSArray *resources = [[NSArray alloc] initWithObjects:imageResource, nil];

    // 最小限のイメージ表示用ENML
    NSString *ENML = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note><en-media type=\"image/%@\" hash=\"%@\"/></en-note>", fileType, hash];

    // Adding the content & resources to the note
    [note setContent:ENML];
    [note setResources:resources];
    [note setCreated:[date timeIntervalSince1970] * 1000];
*/
    // 送信
    // FIXME:コンパイル通らないのでとりあえずコメントアウト
//    [self.noteStoreClient createNote:[EvernoteAuthToken sharedInstance].authToken :note];
}

@end
