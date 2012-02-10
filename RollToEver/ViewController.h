//
//  ViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RollToEver.h"

@interface ViewController : UIViewController
{
    RollToEver *rollToEver_;
}

- (IBAction)start:(id)sender;
@property (retain, nonatomic) IBOutlet UIProgressView *UploadProgress;
@property (retain, nonatomic) IBOutlet UILabel *ProgressText;
@property (assign) NSInteger numOfPhotos;

@end
