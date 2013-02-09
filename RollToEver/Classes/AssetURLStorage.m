//
//  AssetURLStorage.m
//  RollToEver
//
//  Created by fifnel on 2012/02/10.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AssetURLStorage.h"

#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface AssetURLStorage ()

@property(readonly, getter=getManagedObjectContext) NSManagedObjectContext *managedObjectContext;

@end


@implementation AssetURLStorage

/**
 CoreDataのManagedObjectContextを取得
 */
- (NSManagedObjectContext *)getManagedObjectContext
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return [appDelegate managedObjectContext];
}

/**
 CoreDataからデータをすべて取得
 */
- (NSArray *)getManagedObjects
{
    return [self getManagedObjectsURL:nil];
}

/**
 任意のURLのデータを取得
 */
- (NSArray *)getManagedObjectsURL:(NSString *)url
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoURL" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];

    if (url != nil) {
        NSString *predicateCommand = [NSString stringWithFormat:@"url='%@'", url];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateCommand];
        [request setPredicate:predicate];
    }

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"(getManagedObjectsURL:)Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    return results;
}

/**
 URLが存在（登録済み）するかどうか
 */
- (BOOL)isExistURL:(NSString *)url
{
    NSArray *results = [self getManagedObjectsURL:url];

    if (results != nil && [results count] > 0) {
        // NSLog(@"isExistURL count=%d", [results count]);
        return YES;
    } else {
        return NO;
    }
}

/**
 URLの追加
 */
- (BOOL)insertURL:(NSString *)url
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoURL" inManagedObjectContext:self.managedObjectContext];

    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];
    [newManagedObject setValue:url forKey:@"url"];

    NSError *error = nil;
    if ([self.managedObjectContext save:&error]) {
        NSLog(@"insertURL:%@", url);
        return YES;
    } else {
        NSLog(@"(insertURL:)Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }
}

/**
 複数のURLの追加
 */
- (BOOL)insertURLs:(NSArray *)urlList
{
    for (NSString *url in urlList) {
        if ([self insertURL:url] == NO) {
            return NO;
        }
    }
    return YES;
}

/**
 URLの削除
 */
- (void)deleteURL:(NSString *)url
{
    NSArray *array = [self getManagedObjectsURL:url];
    if (array == nil) {
        return;
    }

    for (int i = 0, end = [array count]; i < end; i++) {
        [self.managedObjectContext deleteObject:(NSManagedObject *) [array objectAtIndex:i]];
    }
    NSLog(@"deleteURL:%@", url);

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"(deleteURL:)Unresolved error %@, %@", error, [error userInfo]);
    }
}

/**
 登録されているURLをすべて削除する
 */
- (void)deleteAllURLs
{
    NSArray *urls = [self getManagedObjects];
    for (int i = 0, end = [urls count]; i < end; i++) {
        NSManagedObject *obj = [urls objectAtIndex:i];
        NSLog(@"delete url=%@", [obj valueForKey:@"url"]);
        [self.managedObjectContext deleteObject:obj];
    }

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"(deleteURL:)Unresolved error %@, %@", error, [error userInfo]);
    }
}

// 登録済みURLを除外する
- (NSArray *)filterdURLList:(NSArray *)urlList
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([self isExistURL:evaluatedObject]) {
            return NO;
        } else {
            return YES;
        }
    }];
    
    return [urlList filteredArrayUsingPredicate:predicate];
}

@end
