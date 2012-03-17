//
//  NSObject+ALAsset_Resize.m
//  RollToEver
//
//  Created by fifnel on 2012/02/23.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ALAsset+Resize.h"

#import <ImageIO/imageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+FileExtCheck.h"

UIImage *scaleAndRotateImage(CGImageRef originalImage, int orientation, float resizeRatio);

UIImage *scaleAndRotateImage(CGImageRef originalImage, int orientation, float resizeRatio)
{
    CGFloat width = CGImageGetWidth(originalImage);
    CGFloat height = CGImageGetHeight(originalImage);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat boundHeight;
    switch(orientation) {
            
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
    
    CGSize resizedSize = CGSizeMake(bounds.size.width*resizeRatio, bounds.size.height*resizeRatio);
    
    UIGraphicsBeginImageContext(resizedSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Y軸方向に一度画像を反転させてから回転処理(CGうんたらとUIうんたらで座標系がY逆らしい）
    CGContextScaleCTM(context, resizeRatio, -resizeRatio);
    CGContextTranslateCTM(context, 0, -bounds.size.height);
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), originalImage);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return imageCopy;
}

@implementation ALAsset (Resize)

// アセット内の写真をリサイズして生データを返す
// maxPixelが0以下の場合はオリジナルサイズのまま返す
- (NSData *)resizedImageData:(NSInteger)maxPixel
{
    static NSString *META_ROOT_ORIENTATION = @"Orientation";
    static NSString *META_TIFF             = @"{TIFF}";
    static NSString *META_TIFF_ORIENTATION = @"Orientation";
    
    ALAssetRepresentation *rep = [self defaultRepresentation];
    NSMutableDictionary *metaData = [[NSMutableDictionary alloc] initWithDictionary:[rep metadata]];
    CGImageRef fullResolution = [rep fullResolutionImage];
    
    CFStringRef fileType = nil;
    NSString *filename = [rep filename];
    if ([filename hasExtension:@".jpg"]) {
        fileType = kUTTypeJPEG;
    } else if ([filename hasExtension:@".png"]) {
        fileType = kUTTypePNG;
    } else {
        // 未対応フォーマット
        return nil;
    }

    // リサイズ・回転処理
    size_t width  = CGImageGetWidth(fullResolution);
    size_t height = CGImageGetHeight(fullResolution);
    if (width==0 || height==0) {
        return nil;
    }
    float ratio = 1.0f;
    if (maxPixel > 0) {
        ratio = sqrtf((float)maxPixel / (float)(width*height));
    }
    NSString *orientationStr = [metaData valueForKey:@"Orientation"];
    int orientation = [orientationStr intValue];
    if (orientation == 0) {
        orientation = 1;
    }
    UIImage *resizedImage = scaleAndRotateImage(fullResolution, orientation, ratio);
    
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
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)resizedImageData, fileType, 1, NULL);
    CGImageDestinationAddImage(destination, [resizedImage CGImage], (__bridge CFDictionaryRef)metaData);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    
    return resizedImageData;
}

@end
