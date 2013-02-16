//
//  Config.h
//  RollToEver
//
//  Created by fifnel on 2012/10/28.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#include "PrivateConfig.h"

// Evernote接続先
#ifdef USE_EVERNOTE_SANDBOX
# define EVERNOTE_HOST       @"sandbox.evernote.com"
#else
# define EVERNOTE_HOST       @"www.evernote.com"
#endif

// アプリケーション名
#define APPLICATION_NAME    @"RollToEver"

// アプリケーションバージョン番号
#define APPLICATION_VERSION @"1.0.5"
