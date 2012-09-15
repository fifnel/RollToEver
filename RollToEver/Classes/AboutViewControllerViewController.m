//
//  AboutViewControllerViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/03/03.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AboutViewControllerViewController.h"
#import "id.h"

@implementation AboutViewControllerViewController

@synthesize applicationName    = _applicationName;
@synthesize applicationVersion = _applicationVersion;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [_applicationName setText:APPLICATION_NAME];
    NSString *ver = [NSString stringWithFormat:@"Ver. %@", APPLICATION_VERSION];
    [_applicationVersion setText:ver];
}

- (void)viewDidUnload
{
    [self setApplicationName:nil];
    [self setApplicationVersion:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
