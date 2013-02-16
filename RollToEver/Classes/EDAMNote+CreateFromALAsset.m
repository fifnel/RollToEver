//
//  EDAMNote+CreateFromALAsset.m
//  RollToEver
//
//  Created by fifnel on 2013/02/05.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "EDAMNote+CreateFromALAsset.h"
#import "ALAsset+TransformForEvernote.h"
#import "NSDataMD5Additions.h"

@implementation EDAMNote (CreateFromALAsset)

// TODO: photoSizeとか渡したくない
// TODO: 変換済みのassetを渡せればそれでいい気がする
+ (EDAMNote *)createFromALAsset:(ALAsset *)asset notebook:(NSString *)notebookGUID photoSize:(NSInteger)photoSize
{
    EDAMNote *note = [[EDAMNote alloc] init];
    
    // 写真撮影日を元にしたタイトル
    NSDateFormatter *titleDateFormatter = [[NSDateFormatter alloc] init];
    [titleDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    note.title = [titleDateFormatter stringFromDate:[asset valueForProperty:ALAssetPropertyDate]];
    note.notebookGuid = notebookGUID;

    // asset(写真)のRollToEver向け変換
    NSData *data = [asset transformForEvernoteWithMaxPixel:photoSize];
    
    // Calculating the md5
    NSString *hash = [[[data md5] description] stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash substringWithRange:NSMakeRange(1, [hash length] - 2)];
    
    // 1) create the data EDAMData using the hash, the size and the data of the image
    EDAMData *imageData = [[EDAMData alloc] initWithBodyHash:[hash dataUsingEncoding:NSASCIIStringEncoding] size:[data length] body:data];
    
    // 2) Create an EDAMResourceAttributes object with other important attributes of the file
    EDAMResourceAttributes *imageAttributes = [[EDAMResourceAttributes alloc] init];
    [imageAttributes setFileName:[asset filename]];
    
    // 3) create an EDAMResource the hold the mime, the data and the attributes
    EDAMResource *imageResource = [[EDAMResource alloc] init];
    [imageResource setMime:[asset MIMEType]];
    [imageResource setData:imageData];
    [imageResource setAttributes:imageAttributes];
    
    // We are transforming the resource into a array to attach it to the note
    NSArray *resources = [[NSArray alloc] initWithObjects:imageResource, nil];
    
    // 最小限のイメージ表示用ENML
    NSString *ENML = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note><en-media type=\"%@\" hash=\"%@\"/></en-note>", [asset MIMEType], hash];
    
    // Adding the content & resources to the note
    [note setContent:ENML];
    [note setResources:resources];
    
    // 作成日を写真の撮影日にする
    [note setCreated:(EDAMTimestamp) ([[asset valueForProperty:ALAssetPropertyDate] timeIntervalSince1970] * 1000)];
    
    return note;
}

@end
