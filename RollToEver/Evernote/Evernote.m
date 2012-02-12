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

#import "Evernote.h"

#import "id.h"
/*
 id.hでは以下の文字列の定義をしています。
 パスワード類をgitにcommitさせないための対処です。
 id.hは無視設定にしてください。
 
 NSString * const consumerKey  = @"consumerKey";
 NSString * const consumerSecret = @"consumerSecret";
 
 NSString * const username = @"username";
 NSString * const password = @"password";  
*/


NSString * const userStoreUri = @"https://sandbox.evernote.com/edam/user";
NSString * const noteStoreUriBase = @"https://sandbox.evernote.com/edam/note/"; 


// NOTE: You must set the Application name and version
// used in the User-Agent
NSString * const applicationName = @"RollToEver";
NSString * const applicationVersion = @"0.0";

@implementation Evernote

@synthesize shardId, authToken, noteStoreUri, user, noteStore;

-(id)initWithUserID:(NSString *)username Password:(NSString *)password {
    self = [super init];
    if (self != nil) {
        username_ = username;
        password_ = password;
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
        
        THTTPClient *userStoreHttpClient = [[[THTTPClient alloc] initWithURL:  NSURLuserStoreUri] autorelease];
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
        THTTPClient *noteStoreHttpClient = [[[THTTPClient alloc] initWithURL:noteStoreUri userAgent: userAgent timeout:15000] autorelease];
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

- (void)dealloc
{
    [noteStore release];
    [super dealloc];

}

@end
