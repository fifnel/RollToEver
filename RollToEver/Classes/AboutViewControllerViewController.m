//
//  AboutViewControllerViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/03/03.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AboutViewControllerViewController.h"
#import "id.h"

@interface AboutViewControllerViewController ()

@end

@implementation AboutViewControllerViewController
@synthesize applicationName;
@synthesize applicationVersion;

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
    
    [applicationName setText:APPLICATIONNAME];
    NSString *ver = [NSString stringWithFormat:@"Ver. %@", APPLICATIONVERSION];
    [applicationVersion setText:ver];
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

- (void)dealloc {
    [applicationName release];
    [applicationVersion release];
    [super dealloc];
}
@end
