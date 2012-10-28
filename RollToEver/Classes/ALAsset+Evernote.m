//
//  ALAsset+Evernote.m
//  RollToEver
//
//  Created by fifnel on 2012/09/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ALAsset+Evernote.h"
#import <ImageIO/imageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSDataMD5Additions.h"

@implementation ALAsset (Evernote)


- (EDAMNote *)createEDAMNote:(NSString *)notebookGUID photoSize:(NSInteger)photoSize
{
    // ノートのタイトルのフォーマット用
    NSDateFormatter *titleDateFormatter = [[NSDateFormatter alloc] init];
    [titleDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSData *data = [self resizedImageData:photoSize];

    NSDate *date = [self valueForProperty:ALAssetPropertyDate];

    NSString *fileType = nil;
    NSString *fileExt = [[self getFileName] pathExtension];
    if ([fileExt caseInsensitiveCompare:@"jpg"] == NSOrderedSame) {
        fileType = @"jpeg";
    } else if ([fileExt caseInsensitiveCompare:@"png"] == NSOrderedSame) {
        fileType = @"png";
    } else if ([fileExt caseInsensitiveCompare:@"gif"] == NSOrderedSame) {
        fileType = @"gif";
    } else {
        // 未対応フォーマット
        NSLog(@"unknown extension:%@", [self getFileName]);
        return nil;
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
    [imageAttributes setFileName:[self getFileName]];

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

    return note;
}

- (NSData *)resizedImageData:(NSInteger)maxPixel
{
    static NSString *META_ROOT_ORIENTATION = @"Orientation";
    static NSString *META_TIFF = @"{TIFF}";
    static NSString *META_TIFF_ORIENTATION = @"Orientation";

    ALAssetRepresentation *rep = [self defaultRepresentation];
    NSMutableDictionary *metaData = [[NSMutableDictionary alloc] initWithDictionary:[rep metadata]];
    CGImageRef fullResolution = [rep fullResolutionImage];

    CFStringRef fileType = nil;
    NSString *fileExt = [[self getFileName] pathExtension];
    if ([fileExt caseInsensitiveCompare:@"jpg"] == NSOrderedSame) {
        fileType = kUTTypeJPEG;
    } else if ([fileExt caseInsensitiveCompare:@"png"] == NSOrderedSame) {
        fileType = kUTTypePNG;
    } else if ([fileExt caseInsensitiveCompare:@"gif"] == NSOrderedSame) {
        fileType = kUTTypeGIF;
    } else {
        // 未対応フォーマット
        return nil;
    }

    // リサイズ・回転処理
    size_t width = CGImageGetWidth(fullResolution);
    size_t height = CGImageGetHeight(fullResolution);
    if (width == 0 || height == 0) {
        return nil;
    }
    float ratio = 1.0f;
    if (maxPixel > 0) {
        ratio = sqrtf((float) maxPixel / (float) (width * height));
    }
    if (ratio > 1.0f) {
        ratio = 1.0f;
    }
    NSString *orientationStr = [metaData valueForKey:@"Orientation"];
    int orientation = [orientationStr intValue];
    if (orientation == 0) {
        orientation = 1;
    }
    UIImage *resizedImage = [ALAsset scaleAndRotateImage:(CGImageRef) fullResolution orientation:(int) orientation resizeRatio:(float) ratio];


    // メタデータ書き込み(Orientationだけは元画像を回転加工済みなので1に固定する)
    if ([metaData valueForKey:META_ROOT_ORIENTATION] != nil) {
        [metaData setValue:[NSNumber numberWithInt:1] forKey:META_ROOT_ORIENTATION];
    }
    if ([metaData valueForKey:META_TIFF] != nil) {
        if ([metaData valueForKey:META_TIFF_ORIENTATION] != nil) {
            [[metaData valueForKey:META_TIFF] setValue:[NSNumber numberWithInt:1] forKey:META_TIFF_ORIENTATION];
            //            [metaData setValue:[NSNumber numberWithInt:1] forKey:META_TIFF_ORIENTATION];
        }
    }
    NSMutableData *resizedImageData = [[NSMutableData alloc] init];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef) resizedImageData, fileType, 1, NULL);
    CGImageDestinationAddImage(destination, [resizedImage CGImage], (__bridge CFDictionaryRef) metaData);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);

    return resizedImageData;
}

- (NSString *)getFileName
{
    ALAssetRepresentation *rep = [self defaultRepresentation];
    return [rep filename];
}

+ (UIImage *)scaleAndRotateImage:(CGImageRef)imageRef orientation:(int)orientation resizeRatio:(float)resizeRatio
{
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);

    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat boundHeight;
    switch (orientation) {

        case 1: //UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;

        case 2: //UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;

        case 3: //UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case 4: //UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;

        case 5: //UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;

        case 6: //UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;

        case 7: //UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;

        case 8: //UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;

        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];

    }

    CGSize resizedSize = CGSizeMake(bounds.size.width * resizeRatio, bounds.size.height * resizeRatio);

    UIGraphicsBeginImageContext(resizedSize);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Y軸方向に一度画像を反転させてから回転処理(CGうんたらとUIうんたらで座標系がY逆らしい）
    CGContextScaleCTM(context, resizeRatio, -resizeRatio);
    CGContextTranslateCTM(context, 0, -bounds.size.height);
    CGContextConcatCTM(context, transform);

    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imageRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return imageCopy;
}

@end
