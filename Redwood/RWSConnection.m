//
//  RWSConnection.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import "RWSConnection.h"
#import "RWSLocationItem.h"
#import "RWSSettingsStore.h"
#import "RWSDebug.h"

static NSMutableArray *sharedConnectionList = nil;

@implementation RWSConnection

@synthesize request, completionBlock;
@synthesize jsonRootObject;

- (id)initWithRequest:(NSURLRequest *)req
{
    self = [super init];
    if(self) {
        [self setRequest:req];
        shouldAllowSelfSignedCert = YES;
    }
    return self;
}

- (void)start
{
    DLog(@"In connection start...");
    // Initialize container for data collected from NSURLConnection
    container = [[NSMutableData alloc] init];
    
    // Spawn connection
    internalConnection = [[NSURLConnection alloc] initWithRequest:[self request]
                                                         delegate:self 
                                                 startImmediately:YES];
    
    // If this is the first connection started, create the array
    if(!sharedConnectionList)
        sharedConnectionList = [[NSMutableArray alloc] init];
    
    // Add the connection to the array so it doesn't get destroyed
    [sharedConnectionList addObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [container appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"In connectionDidFinishLoading");
    id rootObject = nil;
    // If there is a "root object"
    if([self jsonRootObject]) {
        // Turn JSON data into model objects
        NSObject *d = [NSJSONSerialization JSONObjectWithData:container 
                                                          options:0 
                                                            error:nil];
        
        // Have the root object pull its data from the dictionary
        [[self jsonRootObject] readFromJSONObject:d];
        
        rootObject = [self jsonRootObject];
    }
    
    // Then, pass the root object to the completion block - remember,
    // this is the block that the controller supplied. 
    if([self completionBlock])
        [self completionBlock](rootObject, nil);
    
    // Now, destroy this connection
    [sharedConnectionList removeObject:self];
}
- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
     DLog(@"In didFailWithError");
    // Pass the error from the connection to the completionBlock
    if([self completionBlock]) 
        [self completionBlock](nil, error);
    
    // Destroy this connection
    [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    DLog(@"In didReceiveResponse");
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;

    httpResponse = (NSHTTPURLResponse *) response;
    
    DLog (@"response status = %d", httpResponse.statusCode);
    
    if ((httpResponse.statusCode/100) == 2){
        contentTypeHeader = [httpResponse MIMEType];
        DLog (@"received content type header = %@", contentTypeHeader);
    }
    
}

// Handle basic authentication challenge if needed
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {    
    DLog(@"In didReceiveAuthenticationChallenge");
    
    NSString *username = @"admin";
    //NSString *password = @"redwood";
    NSString *password = [[[RWSSettingsStore defaultStore] settings] password];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username
                                                             password:password
                                                          persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space {
    DLog(@"In canAuthenticateAgainstProtectionSpace");
    if([[space authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if(shouldAllowSelfSignedCert) {
            return YES; // Self-signed cert will be accepted
        } else {
            return NO;  // Self-signed cert will be rejected
        }
        // Note: it doesn't seem to matter what you return for a proper SSL cert
        //       only self-signed certs
    }
    // If no other authentication is required, return NO for everything else
    // Otherwise maybe YES for NSURLAuthenticationMethodDefault and etc.
    return NO;
}

@end
