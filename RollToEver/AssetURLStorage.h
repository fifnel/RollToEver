//
//  AssetURLStorage.h
//  RollToEver
//
//  Created by fifnel on 2012/02/10.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssetURLStorage : NSObject

- (BOOL)isExistURL:(NSString *)url;
- (BOOL)insertURL:(NSString *)url;
- (void)deleteURL:(NSString *)url;
- (void)deleteAllURLs;

@end
