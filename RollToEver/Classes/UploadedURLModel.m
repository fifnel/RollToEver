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

@implementation UploadedURLModel

// CoreDataのManagedObjectContextを取得
+ (NSManagedObjectContext *)managedObjectContext
{
    id appDelegate = [UIApplication sharedApplication].delegate;
    return [appDelegate managedObjectContext];
}

+ (NSArray *)loadAllUploadedURL
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

+ (id)loadUploadedURL:(NSString *)url
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

+ (BOOL)isUploadedURL:(NSString *)url
{
    id target = [self loadUploadedURL:url];

    if (target == nil) {
        return NO;
    }

    return YES;
}

+ (BOOL)saveUploadedURL:(NSString *)url
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

+ (BOOL)saveUploadedURLList:(NSArray *)urlList
{
    for (NSString *url in urlList) {
        if ([self saveUploadedURL:url] == NO) {
            return NO;
        }
    }
    return YES;
}

+ (void)deleteUploadedURL:(NSString *)url
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

+ (void)deleteAllUploadedURL
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
