//
//  Evernote.m
//  
//  A simple application demonstrating the use of the Evernote API
//  on iOS.
//
//  Before running this sample, you must change the API consumer key
//  and consumer secret to the values that you received from Evernote.
//
//  Evernote API sample code is provided under the terms specified 
//  in the file LICENSE.txt which was included with this distribution.
//
// modified by fifnel

#import "Evernote.h"

#import "NSString+MD5.h"
#import "NSDataMD5Additions.h"
#import "THTTPAsyncClient.h"

#import "id.h"
/*
 id.hでは以下の文字列の定義をしています。
 パスワード類をgitにcommitさせないための対処です。
 id.hは無視設定にしてください。
 
 NSString * const consumerKey  = @"consumerKey";
 NSString * const consumerSecret = @"consumerSecret";

 */


NSString * const userStoreUri = @"https://sandbox.evernote.com/edam/user";
NSString * const noteStoreUriBase = @"https://sandbox.evernote.com/edam/note/"; 


// NOTE: You must set the Application name and version
// used in the User-Agent
NSString * const applicationName = @"RollToEver";
NSString * const applicationVersion = @"0.0";

@implementation Evernote

@synthesize shardId, authToken, noteStoreUri, user, noteStore;
@synthesize delegate = delegate_;

-(id)initWithUserID:(NSString *)username Password:(NSString *)password {
    self = [super init];
    if (self != nil) {
        username_ = username;
        password_ = password;
        
        titleDateFormatter_ = [[NSDateFormatter alloc] init];
        [titleDateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
  return self;
}

/************************************************************
 *
 *  Connecting to the Evernote server using simple
 *  authentication
 *
 ************************************************************/

- (void) connect {
    
    if (authToken == nil) 
    {      
        // In the case we are not connected we don't have an authToken
        // Instantiate the Thrift objects
        NSURL * NSURLuserStoreUri = [[[NSURL alloc] initWithString: userStoreUri] autorelease];
        
        THTTPAsyncClient *userStoreHttpClient = [[[THTTPAsyncClient alloc] initWithURL:  NSURLuserStoreUri] autorelease];
        TBinaryProtocol *userStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:userStoreHttpClient] autorelease];
        EDAMUserStoreClient *userStore = [[[EDAMUserStoreClient alloc] initWithProtocol:userStoreProtocol] autorelease];
        
        
        // Check that we can talk to the server
        bool versionOk = [userStore checkVersion: applicationName :[EDAMUserStoreConstants EDAM_VERSION_MAJOR] :    [EDAMUserStoreConstants EDAM_VERSION_MINOR]];
        
        if (!versionOk) {
           // Alerting the user that the note was created
            UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle: @"Evernote" message: @"Incompatible EDAM client protocol version" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            
            [alertDone show];
            [alertDone release];
            
            return;
        }
        
 
        // Returned result from the Evernote servers after authentication
        EDAMAuthenticationResult* authResult =[userStore authenticate:username_ :password_ : consumerKey :consumerSecret];
        
        // User object describing the account
        self.user = [authResult user];
        // We are going to save the authentication token
        self.authToken = [authResult authenticationToken];
        // and the shard id
        self.shardId = [user shardId];
        
        // Creating the user's noteStore's URL
        noteStoreUri =  [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", noteStoreUriBase, shardId] ] autorelease];
        
        // Creating the User-Agent
        UIDevice *device = [UIDevice currentDevice];
        NSString * userAgent = [NSString stringWithFormat:@"%@/%@;%@(%@)/%@", applicationName,applicationVersion, [device systemName], [device model], [device systemVersion]]; 
        
        
        // Initializing the NoteStore client
        THTTPAsyncClient *noteStoreHttpClient = [[[THTTPAsyncClient alloc] initWithURL:noteStoreUri userAgent: userAgent timeout:15000] autorelease];
        noteStoreHttpClient.delegate = delegate_;
        TBinaryProtocol *noteStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:noteStoreHttpClient] autorelease];
        noteStore = [[[EDAMNoteStoreClient alloc] initWithProtocol:noteStoreProtocol] retain];
        
    }
}

/************************************************************
 *
 *  Listing all the user's notebooks
 *
 ************************************************************/

- (NSArray *) listNotebooks {   
    
    // Checking the connection
    [self connect];
    
    // Calling a function in the API
    NSArray *notebooks = [[NSArray alloc] initWithArray:[[self noteStore] listNotebooks:authToken] ];
    
    return notebooks;
}


/************************************************************
 *
 *  Searching for notes using a EDAM Note Filter
 *
 ************************************************************/

- (EDAMNoteList *) findNotes: (EDAMNoteFilter *) filter {
    // Checking the connection
    [self connect];
    
    
    // Calling a function in the API 
    return [noteStore findNotes:authToken:filter:0 :100];
}


/************************************************************
 *
 *  Loading a note using the guid
 *
 ************************************************************/

- (EDAMNote *) getNote: (NSString *) guid {
    // Checking the connection
    [self connect];
    
    // Calling a function in the API
    return [noteStore getNote:authToken :guid :true :true :true :true];
}


/************************************************************
 *
 *  Deleting a note using the guid
 *
 ************************************************************/

- (void) deleteNote: (NSString *) guid {
    // Checking the connection
    [self connect];

    // Calling a function in the API
    [noteStore deleteNote:authToken :guid];
}


/************************************************************
 *
 *  Creating a note
 *
 ************************************************************/

- (void) createNote: (EDAMNote *) note {
    // Checking the connection
    [self connect];

    // Calling a function in the API
    [noteStore createNote:authToken :note];
}

/**
 Creating a note and Upload photo

 modified
   from
     evernote-api-1.20/cocoa/sample/client/addNoteViewController.m
       -(IBAction)sendNoteEvernote:(id)sender;
 by fifnel
 */
- (void)uploadPhoto:(NSData *)image notebookGUID:(NSString *)notebookGUID date:(NSDate *)date filename:(NSString *)filename {
    
    NSUInteger imageSize = [image length];
    if (imageSize <= 0) {
        return;
    }
    
    EDAMNote *note = [[[EDAMNote alloc] init] autorelease];
    note.title = [titleDateFormatter_ stringFromDate:date];
    if (notebookGUID != nil) {
        note.notebookGuid = notebookGUID;
    }
    
    // Calculating the md5
    NSString *hash = [[[image md5] description] stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash substringWithRange:NSMakeRange(1, [hash length] - 2)];
    
    // 1) create the data EDAMData using the hash, the size and the data of the image
    EDAMData *imageData = [[[EDAMData alloc] initWithBodyHash:[hash dataUsingEncoding: NSASCIIStringEncoding] size:[image length] body:image] autorelease];
    
    // 2) Create an EDAMResourceAttributes object with other important attributes of the file
    EDAMResourceAttributes *imageAttributes = [[[EDAMResourceAttributes alloc] init] autorelease];
    [imageAttributes setFileName:filename];
    
    // 3) create an EDAMResource the hold the mime, the data and the attributes
    EDAMResource *imageResource  = [[[EDAMResource alloc] init] autorelease];
    [imageResource setMime:@"image/jpeg"];
    [imageResource setData:imageData];
    [imageResource setAttributes:imageAttributes];
    
    // We are quickly the ENML code for the image to the content
    NSString *ENML = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note><en-media type=\"image/jpeg\" hash=\"%@\"/></en-note>", hash];
    
    // We are transforming the resource into a array to attach it to the note
    NSArray *resources = [[NSArray alloc] initWithObjects:imageResource, nil];
    
    NSLog(@"%@", ENML);
    
    // Adding the content & resources to the note
    [note setContent:ENML];
    [note setResources:resources];
    [note setCreated:[date timeIntervalSince1970]*1000];
    
    // Saving the note on the Evernote servers
    // Simple error management
    @try {
        [self createNote:note];
    }
    @catch (EDAMUserException * e) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error saving note: error code %i", [e errorCode]];
        UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle: @"Evernote" message: errorMessage delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        
        [alertDone show];
        [alertDone release];
        return;
    }
}

- (void)dealloc
{
    [noteStore release];
    [super dealloc];

}

@end
