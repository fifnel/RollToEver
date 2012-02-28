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

@implementation ALAsset (Resize)

// アセット内の写真をリサイズして生データを返す
// maxPixelが0以下の場合はオリジナルサイズのまま返す
- (NSData *)resizedImageData:(NSInteger)maxPixel
{
    ALAssetRepresentation *rep = [self defaultRepresentation];
    NSDictionary *metaData = [rep metadata];
    CGImageRef fullResolution = [rep fullResolutionImage];
    size_t width  = CGImageGetWidth(fullResolution);
    size_t height = CGImageGetHeight(fullResolution);
    if (width==0 || height==0) {
        return nil;
    }

    NSMutableData *resizedImageData = [[[NSMutableData alloc] init] autorelease];
    float ratio = 0.0f;
    if (maxPixel > 0) {
        ratio = sqrtf((float)maxPixel / (float)(width*height));
    }
    if (maxPixel > 0 && ratio < 1.0f) {
        size_t newWidth  = width*ratio;
        size_t newHeight = height*ratio;
        
        // 縮小処理
        UIImage *originalImage = [UIImage imageWithCGImage:fullResolution];
        UIImage *resizedImage;
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [originalImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // メタデータ書き込み
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)resizedImageData, kUTTypeJPEG, 1, NULL);
        CGImageDestinationAddImage(destination, [resizedImage CGImage], (CFDictionaryRef)metaData);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
    } else {
        // 縮小処理なしでバイト列を返す
        NSUInteger size = [rep size];
        [resizedImageData setLength:size];
        NSError *error = nil;
        [rep getBytes:[resizedImageData mutableBytes] fromOffset:0 length:size error:&error];
        if (error) {
            NSLog(@"error:%@", error);
            return nil;
        }
    }
    
    /*
     #if 0
     // これだとExifおちる
     UIImage *uiImg = [[UIImage alloc] initWithData:imageSrc];
     UIImageWriteToSavedPhotosAlbum(uiImg, nil, nil, nil);
     #else
     // これだとExifかきこめる
     ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
     CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)imageSrc);
     CGImageRef cgImage = CGImageCreateWithJPEGDataProvider(imgDataProvider, nil, true, kCGRenderingIntentDefault);
     [assetsLibrary writeImageToSavedPhotosAlbum:cgImage metadata:meta completionBlock:nil];
     
     // assetsLibraryのreleaseできてない、テストなのでとりあえずリークさせとく
     #endif
     */
    
    return resizedImageData;
}

@end
