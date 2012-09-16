//
//  TestViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/09/16.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "TestViewController.h"
#import "EvernoteSDK.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 3;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"EvernoteSendTest";
            break;
        default:
            cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
            break;
            
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self testSendEvernote];
            break;
            
        default:{
            UIAlertView *alert = [
                                  [UIAlertView alloc]
                                  initWithTitle : @"Alert!"
                                  message : @"HelloWorld!!"
                                  delegate : self
                                  cancelButtonTitle : @"Cancel"
                                  otherButtonTitles : @"OK", @"aaa", nil
                                  ];
            [alert show];
        }
            break;
    }
}

- (void)testSendEvernote
{
    EDAMNote *note = [[EDAMNote alloc] init];
    note.title = @"note.title";
    note.content = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note>note.content</en-note>";
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    
    @try {
        [noteStore createNote:note success:^(EDAMNote *note) {} failure:^(NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    @catch (EDAMUserException *e) {
        return;
    }
    
    NSLog(@"Note was saved.");
}

@end
