//
//  UploadViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/12.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "UploadViewController.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@implementation UploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    enumerator_ = [[AssetsEnumerator alloc] init];
    enumerator_.delegate = self;
    urls_ = [[NSMutableArray alloc] init];
    assetUrlStorage_ = [[AssetURLStorage alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [assetUrlStorage_ release];
    [urls_ release];
    [enumerator_ release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)AssetsEnumerationStart:(NSInteger)count {
    [urls_ release];
    urls_ = [[NSMutableArray alloc] init];
}

- (void)AssetsEnumerationEnd {
    // ここになんか処理書く
    NSString *msg = [NSString stringWithFormat:@"%d枚のアップロード対象画像が見つかりました。", [urls_ count]];
    UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle:@"RoolToEver" message:msg delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [alertDone show];
    [alertDone release];
    NSLog(@"enumeration finish  count=%d", [urls_ count]);
/*
    ここで「ｘ枚の画像が見つかりました。アップロード開始しますか？」で
    アップロード開始
    1枚ずつURLからasset取得して、Evernoteアップメソッドに投げる
    それら全部このクラスにとりあえず実装してよし
    Evernoteクラスはユーザー名、パスワード、アップロード先ノートブックのGUIDを引数にinitできるようにする
    NSLog(@"enumeration finish  count=%d", [urls_ count]);
 */
}

- (void)AssetsEnumerationFind:(ALAsset *)asset index:(NSInteger)index stop:(BOOL *)stop{
    if (asset == nil) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        if (![assetUrlStorage_ isExistURL:[rep.url absoluteString]]) {
            [urls_ addObject:rep.url];
        }
    }
}

- (void)AssetsEnumerationFailure:(NSError *)error {
}

@end
