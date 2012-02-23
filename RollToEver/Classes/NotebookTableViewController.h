//
//  NotebookTableViewController.h
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Evernote.h"

@interface NotebookTableViewController : UITableViewController
{
@private
    NSArray *notebooksList_;
    NSInteger notebooksNum_;
    Evernote *evernote_;
}

@end
