//
//  UploadAssetListViewController.m
//  RollToEver
//
//  Created by fifnel on 2012/02/18.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "UploadAssetListViewController.h"
#import "PhotoUploadOperation.h"

@interface UploadAssetListViewController()
- (void)updateProgress:(NSDictionary *)params;
- (void)resetProgressAsyncIndex:(NSInteger)index;
- (void)fullProgressAsyncIndex:(NSInteger)index;
- (void)updateProgressAsyncIndex:(NSInteger)index progress:(NSInteger)progress max:(NSInteger)max;
@end

@implementation UploadAssetListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (assetsLoader_ != nil) {
        [assetsLoader_ release];
    }
    assetsLoader_ = [[AssetsLoader alloc] init];
    if (operationQueue_ != nil) {
        [operationQueue_ release];
    }
    operationQueue_ = [[NSOperationQueue alloc] init];
    if (urlStorage_ != nil) {
        [urlStorage_ release];
    }
    urlStorage_ = [[AssetURLStorage alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [assetsLoader_ release];
    assetsLoader_ = nil;
    [operationQueue_ release];
    operationQueue_ = nil;
    [urlStorage_ release];
    urlStorage_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    assetsList_ = [[assetsLoader_ EnumerateURLExcludeDuplication:NO] retain];
    NSLog(@"count=%d", [assetsList_ retainCount]);
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"count=%d", [assetsList_ retainCount]);
    return [assetsList_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger index = [indexPath row];
    ALAsset *asset = [assetsLoader_ loadAssetURLString:[assetsList_ objectAtIndex:index]];
    UIImage *thumb = [[[UIImage alloc] initWithCGImage:[asset thumbnail]] autorelease];
    
    // Configure the cell...
//    [[cell textLabel] setText:[assetsList objectAtIndex:index]];
    [[cell imageView] setImage:thumb];
    UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    
    // サムネイルは正方形なので、高さ＝幅ということにしてプログレスバーの位置を調整する
    CGRect rect = [cell bounds];
    rect.origin.x += rect.size.height;
    rect.size.width -= rect.size.height;
    rect.origin.y += rect.size.height/2;
    progress.frame = rect;
    [cell addSubview:progress];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (IBAction)startUpload:(id)sender {
    uploadIndex_ = 0;
    ALAsset *asset = [assetsLoader_ loadAssetURLString:[assetsList_ objectAtIndex:uploadIndex_]];
    PhotoUploadOperation *ope = [[PhotoUploadOperation alloc] initWithAsset:asset];
    ope.delegate = self;
    [operationQueue_ addOperation:ope];
    [ope release];
}

#pragma mark - UpdateProgress

- (void)updateProgress:(NSDictionary *)params {
    NSNumber *index    = [params valueForKey:@"index"];
    NSNumber *progress = [params valueForKey:@"progress"];
    NSNumber *max      = [params valueForKey:@"max"];
    
    UITableView *tableView = [self tableView];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0]];
    UIProgressView *progressView = [[cell subviews] objectAtIndex:1];
    [progressView setProgress:[progress floatValue]/[max floatValue] animated:YES];
    [cell setNeedsLayout];
}

- (void)resetProgressAsyncIndex:(NSInteger)index {
    [self updateProgressAsyncIndex:index progress:0 max:1];
}

- (void)fullProgressAsyncIndex:(NSInteger)index {
    [self updateProgressAsyncIndex:index progress:1 max:1];
}

- (void)updateProgressAsyncIndex:(NSInteger)index progress:(NSInteger)progress max:(NSInteger)max {
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSNumber numberWithInteger:index],    @"index",
                            [NSNumber numberWithInteger:progress], @"progress",
                            [NSNumber numberWithInteger:max],      @"max",
                            nil];
    [self performSelectorOnMainThread:@selector(updateProgress:) withObject:params waitUntilDone:YES];
}

- (void)PhotoUploadOperationStart:(PhotoUploadOperation *)operation {
    [self resetProgressAsyncIndex:uploadIndex_];
}

- (void)PhotoUploadOperation:(PhotoUploadOperation *)operation progress:(NSInteger)progress max:(NSInteger)max {
    [self updateProgressAsyncIndex:uploadIndex_ progress:progress max:max];
}

- (void)PhotoUploadOperationFinish:(PhotoUploadOperation *)operation {
    [self fullProgressAsyncIndex:uploadIndex_];
    ALAsset *currentAsset = [assetsLoader_ loadAssetURLString:[assetsList_ objectAtIndex:uploadIndex_]];
    ALAssetRepresentation *rep = [currentAsset defaultRepresentation];
    [urlStorage_ insertURL:[rep.url absoluteString]];
    
    uploadIndex_++;
    if (uploadIndex_ < [assetsList_ count]) {
        ALAsset *asset = [assetsLoader_ loadAssetURLString:[assetsList_ objectAtIndex:uploadIndex_]];
        PhotoUploadOperation *ope = [[PhotoUploadOperation alloc] initWithAsset:asset];
        ope.delegate = self;
        [operationQueue_ addOperation:ope];
        [ope release];
    }
}

@end
