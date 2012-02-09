//
//  CoreDataTest.m
//  RollToEver
//
//  Created by fifnel on 2012/02/09.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "CoreDataTest.h"

#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@implementation CoreDataTest

// All code under test must be linked into the Unit Test bundle
- (void)testMath
{
    STAssertTrue((1 + 1) == 2, @"Compiler isn't feeling well today :-(");
}

- (void) testCoreData
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    { // まずは追加
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoURL" inManagedObjectContext:context];
        
        NSManagedObject *newManagedObject1 = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [newManagedObject1 setValue:@"foo" forKey:@"url"];
        
        NSManagedObject *newManagedObject2 = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [newManagedObject2 setValue:@"bar" forKey:@"url"];
        
        NSManagedObject *newManagedObject3 = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [newManagedObject3 setValue:@"hoge" forKey:@"url"];

        NSError *error = nil;
        if (![context save:&error]) {
            STFail(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    { // 読み込み
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoURL" inManagedObjectContext:context];
        [request setEntity:entity];
        
        NSString *predicateCommand = [NSString stringWithFormat:@"url='"];
        predicateCommand = [predicateCommand stringByAppendingFormat:@"foo"];
        predicateCommand = [predicateCommand stringByAppendingFormat:@"'"];
        NSPredicate  *predicate = [NSPredicate predicateWithFormat:predicateCommand];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        if (error) {
            STFail(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        NSLog(@"%@", results);
    }
}

@end
