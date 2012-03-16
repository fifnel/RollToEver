//
//  GCDSingleton.h
//  RollToEver
//
//  Created by fifnel on 2012/03/17.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//
// ex)https://gist.github.com/1057420

/*!
 * @function Singleton GCD Macro
 */
#ifndef SINGLETON_GCD
#define SINGLETON_GCD(classname)                        \
\
+ (classname *)sharedInstance {                      \
\
static dispatch_once_t pred;                        \
__strong static classname * shared##classname = nil;\
dispatch_once( &pred, ^{                            \
shared##classname = [[self alloc] init]; });    \
return shared##classname;                           \
}                                                           
#endif
