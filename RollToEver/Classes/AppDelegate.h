//
//  AppDelegate.h
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

@property(strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property(strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

@end
