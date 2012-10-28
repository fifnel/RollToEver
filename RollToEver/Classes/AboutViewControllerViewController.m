//
//  AboutViewControllerViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/03/03.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "Config.h"

#import "AboutViewControllerViewController.h"

@implementation AboutViewControllerViewController

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

    [self.applicationNameLabel setText:APPLICATION_NAME];
    NSString *ver = [NSString stringWithFormat:@"Ver. %@", APPLICATION_VERSION];
    [self.applicationVersionLabel setText:ver];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
