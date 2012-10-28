//
//  Config.h
//  RollToEver
//
//  Created by fifnel on 2012/10/28.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//



#ifndef RollToEver_Config_h
#define RollToEver_Config_h

#include "PrivateConfig.h"

#ifdef USE_EVERNOTE_SANDBOX
# define EVERNOTE_HOST       @"sandbox.evernote.com"
#else
# define EVERNOTE_HOST       @"www.evernote.com"
#endif

#define APPLICATION_NAME    @"RollToEver"
#define APPLICATION_VERSION @"1.0.5"

#endif
