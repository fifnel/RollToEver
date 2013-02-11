//
//  EvernoteSession+Login.h
//  RollToEver
//
//  Created by fifnel on 2012/09/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteSession.h"

@interface EvernoteSession (Login)

// Evernoteログインをする（してない場合はID/PASS入力画面を出す)
+ (BOOL)loginWithViewController:(UIViewController *)viewController;

@end
