//
//  EDAMNote+CreateFromALAsset.h
//  RollToEver
//
//  Created by fifnel on 2013/02/05.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "EDAMTypes.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface EDAMNote (CreateFromALAsset)

// ALAssetからRollToEverで送信するのに適した形のノートを生成する
+ (EDAMNote *)createFromALAsset:(ALAsset *)asset notebook:(NSString *)notebookGUID photoSize:(NSInteger)photoSize;

@end
