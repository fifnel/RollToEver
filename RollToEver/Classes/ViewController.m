//
//  ViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ViewController.h"
#import "AssetsLoader.h"
#import "MBProgressHUD.h"
#import <dispatch/dispatch.h>

@interface ViewController()

- (void)assetsCountDidFinish;

@property (assign, nonatomic, readwrite) NSInteger photoCount;
@property (retain, nonatomic, readwrite) IBOutlet UILabel *photoCountInfo;

@end

@implementation ViewController

@synthesize photoCount = photoCount_;
@synthesize photoCountInfo = photoCountInfo_;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = @"Loading";

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AssetsLoader *assetsLoader = [[AssetsLoader alloc] init];
        NSArray *assets = [assetsLoader EnumerateURLExcludeDuplication:YES];
        photoCount_ = [assets count];
        [assetsLoader release];
        
        [self performSelectorOnMainThread:@selector(assetsCountDidFinish) withObject:nil waitUntilDone:YES];
    });
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)dealloc {
    self.photoCountInfo = nil;

    [super dealloc];
}

- (void)assetsCountDidFinish {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];

    
    NSString *photoCountStr = [NSString stringWithFormat:NSLocalizedString(@"MainViewPhotoCount", @"Photo Count for MainView"), photoCount_];
    photoCountInfo_.text = photoCountStr;
}

@end
