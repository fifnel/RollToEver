//
//  MainViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ALAssetsLibrary+FilteredList.h"
#import "MBProgressHUD.h"
#import "EvernoteSDK.h"
#import "EvernoteSession+Login.h"


@interface MainViewController ()

@property(assign, nonatomic, readwrite) NSInteger photoCount;

@end

@implementation MainViewController {
    __strong MBProgressHUD *_hud;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (BOOL)isSimulator
{
    return [[[UIDevice currentDevice] model] hasSuffix:@"Simulator"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
#ifndef ENABLE_TEST_MODE
    self.testModeButton.hidden = YES;
#endif
    _skipUpdatePhotoCount = NO;
    if (_hud != nil) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        _hud = nil;
    }

    // Evernoteにログインする
    [EvernoteSession loginWithViewController:self];


    NSString *privacyAlertMessage = nil;

    // 大元の位置情報サービスがオンになっているか
    if (![CLLocationManager locationServicesEnabled]) {
        privacyAlertMessage = NSLocalizedString(@"CLServicesDisable", @"");
    } else {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined:
                // 未選択状態
                // これからどうするか自動的に聞かれるので放っておく
                break;
            case kCLAuthorizationStatusRestricted:
                // ペアレンタルコントロールで制限されている
                privacyAlertMessage = NSLocalizedString(@"CLAuthorizationStatusRestricted", @"");
                break;
            case kCLAuthorizationStatusDenied:
                // アプリが不許可になっている
                privacyAlertMessage = NSLocalizedString(@"CLAuthorizationStatusDenied", @"");
                break;
            case kCLAuthorizationStatusAuthorized:
            default:
                // OK
                break;
        }
    }
    if (privacyAlertMessage) {
        UIAlertView *alert = [
                              [UIAlertView alloc]
                              initWithTitle : @"Notice"
                              message : privacyAlertMessage
                              delegate : self
                              cancelButtonTitle : @"OK"
                              otherButtonTitles:nil
                              ];
        [alert show];
    }
}

- (void)viewDidUnload
{
    if (_hud != nil) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        _hud = nil;
    }
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!_hud) {
        if (!_skipUpdatePhotoCount) {
            [_uploadButton setEnabled:NO];
            [self updatePhotoCount];
        } else {
            [self assetsCountDidFinish];
        }
        _skipUpdatePhotoCount = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)refreshPhotoCount:(id)sender
{
    [self updatePhotoCount];
}

- (void)updatePhotoCount
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = NSLocalizedString(@"Loading", "Now Loading");

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        NSArray *filteredAssetURLList = [assetsLibrary filteredAssetsURLList];
        self.photoCount = [filteredAssetURLList count];

        [self performSelectorOnMainThread:@selector(assetsCountDidFinish) withObject:nil waitUntilDone:YES];
    });
}

- (void)assetsCountDidFinish
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    _hud = nil;

    if (self.photoCount > 0) {
        NSString *photoCountStr = [NSString stringWithFormat:NSLocalizedString(@"MainViewPhotoCount", @"Photo Count for MainView"), self.photoCount];
        self.photoCountLabel.text = photoCountStr;
        [_uploadButton setEnabled:YES];
    } else {
        self.photoCountLabel.text = NSLocalizedString(@"MainViewPhotoNotFound", @"Photo Not Found for MainView");
        [_uploadButton setEnabled:NO];
    }
}

@end
