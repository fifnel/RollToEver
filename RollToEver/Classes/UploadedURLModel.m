//
//  UploadedURLModel.m
//  RollToEver
//
//  Created by fifnel on 2012/02/10.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "UploadedURLModel.h"

#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface UploadedURLModel ()

@property(readonly, getter=getManagedObjectContext) NSManagedObjectContext *managedObjectContext;

@end

/*
 
 各関数はstaticで良いんじゃ無いか
 
 getManagedObjectsURL　の引数が気持ち悪い
 predicate渡すようにして、executeうんたら　の方がいいか
 
 クラス名変えたい
 UploadedURLModel
 
 
 - (BOOL)isExistURL:(NSString *)url;
 
 - (BOOL)saveUploadedURL:(NSString *)url;
 
 - (BOOL)saveUploadedURLList:(NSArray *)urlList;
 
 - (void)deleteURL:(NSString *)url;
 
 - (void)deleteAllURLs;

 
 
 - (NSManagedObjectContext *)getManagedObjectContext
 - (NSArray *)loadAllUploadedURL
 - (NSArray *)loadUploadedURL:(NSString *)url

 fetch

 save

 fetchUploadedURLFromCoreData

 loadUploadedURL
 loadAllUploadedURL
 
 */


@implementation UploadedURLModel

/**
 CoreDataのManagedObjectContextを取得
 */
- (NSManagedObjectContext *)getManagedObjectContext
{
    id appDelegate = [UIApplication sharedApplication].delegate;
    return [appDelegate managedObjectContext];
}

/**
 CoreDataからデータをすべて取得
 */
- (NSArray *)loadAllUploadedURL
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoURL" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"(loadAllUploadedURL:)Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    return results;
}

/**
 CoreDataから任意のデータを取得
 */
- (id)loadUploadedURL:(NSString *)url
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoURL" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];

    NSString *predicateCommand = [NSString stringWithFormat:@"url='%@'", url];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateCommand];
    [request setPredicate:predicate];

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"(loadUploadedURL:)Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    if ([results count] == 0) {
        return nil;
    } else {
        return [results objectAtIndex:0];
    }
}

/**
 URLが存在（登録済み）するかどうか
 */
- (BOOL)isExistURL:(NSString *)url
{
    id target = [self loadUploadedURL:url];

    if (target == nil) {
        return NO;
    }

    return YES;
}

/**
 URLの追加
 */
- (BOOL)saveUploadedURL:(NSString *)url
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoURL" inManagedObjectContext:self.managedObjectContext];

    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];
    [newManagedObject setValue:url forKey:@"url"];

    NSError *error = nil;
    if ([self.managedObjectContext save:&error]) {
        NSLog(@"saveUploadedURL:%@", url);
        return YES;
    } else {
        NSLog(@"(saveUploadedURL:)Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }
}

/**
 複数のURLの追加
 */
- (BOOL)saveUploadedURLList:(NSArray *)urlList
{
    for (NSString *url in urlList) {
        if ([self saveUploadedURL:url] == NO) {
            return NO;
        }
    }
    return YES;
}

/**
 URLの削除
 */
- (void)deleteUploadedURL:(NSString *)url
{
    id target = [self loadUploadedURL:url];
    if (target == nil) {
        return;
    }

    [self.managedObjectContext deleteObject:(NSManagedObject *) target];
    NSLog(@"deleteURL:%@", url);

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"(deleteURL:)Unresolved error %@, %@", error, [error userInfo]);
    }
}

/**
 登録されているURLをすべて削除する
 */
- (void)deleteAllUploadedURL
{
    NSArray *urls = [self loadAllUploadedURL];
    for (int i = 0, end = [urls count]; i < end; i++) {
        NSManagedObject *obj = [urls objectAtIndex:(NSUInteger) i];
        NSLog(@"delete url=%@", [obj valueForKey:@"url"]);
        [self.managedObjectContext deleteObject:obj];
    }

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"(deleteURL:)Unresolved error %@, %@", error, [error userInfo]);
    }
}


@end
