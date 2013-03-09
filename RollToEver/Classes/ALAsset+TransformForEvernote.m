//
//  ALAsset+TransformForEvernote.m
//  RollToEver
//
//  Created by fifnel on 2013/02/04.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "ALAsset+TransformForEvernote.h"
#import <ImageIO/imageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "RollToEverCommonException.h"
#import "UnsupportedFormatException.h"

@implementation ALAsset (TransformForEvernote)

+ (CFStringRef)stringToUTType:(NSString *)extension
{
    // TODO: 他のフォーマットにも対応したい bmpとかjpg2000とか
    // TODO: pairのようなフォーマットを使ってもう少しスマートに書きたい
    if ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame) {
        return kUTTypeJPEG;
    } else if ([extension caseInsensitiveCompare:@"png"] == NSOrderedSame) {
        return kUTTypePNG;
    } else if ([extension caseInsensitiveCompare:@"gif"] == NSOrderedSame) {
        return kUTTypeGIF;
    } else if ([extension caseInsensitiveCompare:@"tif"] == NSOrderedSame ||
              ([extension caseInsensitiveCompare:@"tiff"] == NSOrderedSame)) {
        return kUTTypeTIFF;
    } else if ([extension caseInsensitiveCompare:@"jp2"] == NSOrderedSame) {
        return kUTTypeJPEG2000;
    } else {
        // 未対応フォーマット
        return NULL;
    }
}

+ (NSString *)stringToMIMEType:(NSString *)extension
{
    // TODO: 他のフォーマットにも対応したい bmpとかjpg2000とか
    // TODO: pairのようなフォーマットを使ってもう少しスマートに書きたい
    if ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame) {
        return @"image/jpeg";
    } else if ([extension caseInsensitiveCompare:@"png"] == NSOrderedSame) {
        return @"image/png";
    } else if ([extension caseInsensitiveCompare:@"gif"] == NSOrderedSame) {
        return @"image/gif";
    } else if ([extension caseInsensitiveCompare:@"tif"] == NSOrderedSame ||
               ([extension caseInsensitiveCompare:@"tiff"] == NSOrderedSame)) {
        return @"image/tiff";
    } else if ([extension caseInsensitiveCompare:@"jp2"] == NSOrderedSame) {
        return @"image/jp2";
    } else {
        // 未対応フォーマット
        return nil;
    }
}

- (NSString *)filename
{
    ALAssetRepresentation *rep = [self defaultRepresentation];
    return [rep filename];
}

- (NSString *)fileExtension
{
    return [[[self filename] pathExtension] lowercaseString];
}

- (CFStringRef)UTType
{
    NSString *extension = [self fileExtension];
    CFStringRef utType = [ALAsset stringToUTType:extension];
    if (!utType) {
        @throw [UnsupportedFormatException exceptionWithFormatName:extension];
    }
    
    return utType;
}

- (NSString *)MIMEType
{
    NSString *extension = [self fileExtension];
    NSString *mimeType = [ALAsset stringToMIMEType:extension];
    if (!mimeType) {
        @throw [UnsupportedFormatException exceptionWithFormatName:extension];
    }
    
    return mimeType;
}

- (float)resizeRatio:(NSInteger)maxPixel
{
    ALAssetRepresentation *rep = [self defaultRepresentation];
    CGImageRef fullResolution = [rep fullResolutionImage];

    size_t width = CGImageGetWidth(fullResolution);
    size_t height = CGImageGetHeight(fullResolution);
    if (width == 0 || height == 0) {
        @throw [RollToEverCommonException
                    exceptionWithFormatName:[NSString stringWithFormat:@"invalid size:width=%ld height=%ld", width, height]];
    }

    float ratio = 1.0f;
    if (maxPixel > 0) {
        ratio = sqrtf((float) maxPixel / (float) (width * height));
    }
    if (ratio > 1.0f) {
        ratio = 1.0f;
    }
    
    return ratio;
}

- (float)orientation
{
    ALAssetRepresentation *rep = [self defaultRepresentation];
    NSString *orientationStr = [[rep metadata] valueForKey:@"Orientation"];
    int orientation = [orientationStr intValue];
    if (orientation == 0) {
        orientation = 1;
    }
    return orientation;
}

- (NSData *)transformForEvernoteWithMaxPixel:(NSInteger)maxPixel
{
    ALAssetRepresentation *rep = [self defaultRepresentation];

    // リサイズ・回転処理
    CGImageRef fullResolution = [rep fullResolutionImage];
    int orientation           = (int) [self orientation];
    float ratio               = [self resizeRatio:maxPixel];
    UIImage *resizedImage     = [ALAsset scaleAndRotateImage:fullResolution orientation:orientation resizeRatio:ratio];
    
    // 書き戻し用のメタデータ組み立て (Orientationだけは元画像を回転加工済みなので1に固定する)
    NSDictionary *metaData = [self fixedMetadata];

    // リサイズ済み画像データとメタデータを合体して新しいイメージデータを生成する 
    NSMutableData *resizedImageData = [[NSMutableData alloc] init];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef) resizedImageData, [self UTType], 1, NULL);
    CGImageDestinationAddImage(destination, [resizedImage CGImage], (__bridge CFDictionaryRef) metaData);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    
    return resizedImageData;
}

//------------------------------------------------------------
// 内部メソッド
//------------------------------------------------------------

// Evernote書き出し用に適したEXIFに変換する
- (NSDictionary *)fixedMetadata
{
    static NSString *META_ROOT_ORIENTATION = @"Orientation";
    static NSString *META_TIFF             = @"{TIFF}";
    static NSString *META_TIFF_ORIENTATION = @"Orientation";

    ALAssetRepresentation *rep = [self defaultRepresentation];
    NSMutableDictionary *metaData = [[NSMutableDictionary alloc] initWithDictionary:[rep metadata]];

    if ([metaData valueForKey:META_ROOT_ORIENTATION] != nil) {
        [metaData setValue:[NSNumber numberWithInt:1] forKey:META_ROOT_ORIENTATION];
    }
    if ([metaData valueForKey:META_TIFF] != nil) {
        if ([metaData valueForKey:META_TIFF_ORIENTATION] != nil) {
            [[metaData valueForKey:META_TIFF] setValue:[NSNumber numberWithInt:1] forKey:META_TIFF_ORIENTATION];
        }
    }

    return metaData;
}

// 拡縮と回転（EXIFの向きをUpにして画像の向きを直す)
+ (UIImage *)scaleAndRotateImage:(CGImageRef)imageRef orientation:(int)orientation resizeRatio:(float)resizeRatio
{
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);

    CGAffineTransform transform;
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
            transform = CGAffineTransformRotate(transform, (CGFloat) M_PI);
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
            transform = CGAffineTransformRotate(transform, (CGFloat) (3.0 * M_PI / 2.0));
            break;

        case 6: //UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, (CGFloat) (3.0 * M_PI / 2.0));
            break;

        case 7: //UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, (CGFloat) (M_PI / 2.0));
            break;

        case 8: //UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, (CGFloat) (M_PI / 2.0));
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
