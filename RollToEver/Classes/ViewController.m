//
//  ViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "ViewController.h"
#import "AssetsLoader.h"

@interface ViewController()

- (void)assetsCountAsync;
- (void)assetsCount;

@property (retain, nonatomic, readwrite) UIView *loadingView;
@property (assign, nonatomic, readwrite) NSInteger photoCount;
@property (retain, nonatomic, readwrite) IBOutlet UILabel *photoCountInfo;

@end

@implementation ViewController

@synthesize loadingView = loadingView_;
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
    self.loadingView = nil;
}

- (void)viewDidUnload
{
    self.loadingView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self performSelectorOnMainThread:@selector(assetsCountAsync) withObject:nil waitUntilDone:NO];
    
    self.loadingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    [self.loadingView setBackgroundColor:[UIColor blackColor]];
    [self.loadingView setAlpha:0.5];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicatorView setCenter:CGPointMake(self.loadingView.bounds.size.width/2, self.loadingView.bounds.size.height/2 )];
    
    [self.loadingView addSubview:indicatorView];
    [self.navigationController.view addSubview: self.loadingView];
    
    [indicatorView startAnimating];
    
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
    self.loadingView = nil;
    self.photoCountInfo = nil;

    [super dealloc];
}

- (void)assetsCountAsync {
    AssetsLoader *assetsLoader = [[AssetsLoader alloc] init];
    NSArray *assets = [assetsLoader EnumerateURLExcludeDuplication:YES];
    photoCount_ = [assets count];
    [assetsLoader release];
    
    [self performSelectorOnMainThread:@selector(assetsCount) withObject:nil waitUntilDone:YES];
}

- (void)assetsCount {
    photoCountInfo_.text = [NSString stringWithFormat:@"%d枚の写真がみつかりました", photoCount_];
    [loadingView_ removeFromSuperview];
    [self setLoadingView:nil];
}

@end
