//
//  RWSLocationItemStore.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import "RWSSettingsStore.h"
#import "RWSLocationItemStore.h"
#import "RWSLocationItem.h"
#import "RWSChannel.h"
#import "RWSConnection.h"
#import "NSString+Encode.h"
#import "NSString+StringUtils.h"
#import "RWSDebug.h"

@implementation RWSLocationItemStore

+ (RWSLocationItemStore *)defaultStore
{
    static RWSLocationItemStore *defaultStore = nil;
    if (!defaultStore){
        defaultStore = [[super allocWithZone:nil]init];
    }
    return defaultStore;
}


//For singleton
+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}

- (id) init
{
    self = [super init];
    if (self) {
        NSString *path = [self itemArchivePath];
        allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If the array hadn't been saved previously, create a new empty one
        if(!allItems)
            allItems = [[NSMutableArray alloc] init];
    }
    return self;
    
}

- (NSArray *) allItems
{
    return allItems;
}

-(RWSLocationItem *) createItem
{
    RWSLocationItem *p = [[RWSLocationItem alloc] init];
    [allItems addObject:p];
    return p;
}

- (void) addItem: (RWSLocationItem *)p
{
    //check if item with same locationId already exists
    int locId = [p locationId];
    for (int i=0; i < [allItems count]; i++){
        if ([[allItems objectAtIndex:i] locationId] == locId){
            return;
        }
    }
    
    [allItems addObject:p];
}

-(void) removeItem:(RWSLocationItem *)p
{
    [allItems removeObjectIdenticalTo:p];
}

- (void) removeAllItems
{
    [allItems removeAllObjects];
}

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to
{
    if (from == to) {
        return;
    }
    // Get pointer to object being moved so we can re-insert it
    RWSLocationItem *p = [allItems objectAtIndex:from];
    
    // Remove p from array
    [allItems removeObjectAtIndex:from];
    
    // Insert p in array at new location
    [allItems insertObject:p atIndex:to];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"locations.archive"];
}

- (BOOL)saveChanges
{
    // returns success or failure
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:allItems
                                       toFile:path];
}


//Method to perform search call on the API
- (void)fetchSearchLocations:(NSString *)searchText withCompletion:(void (^)(RWSChannel *obj, NSError *err))block
{
    DLog(@"In fetchSearchLocations...");
    // Prepare a request URL, including the argument from the controller
    //location/$name:"+locStr;
    
    NSString *encodedSearchText = [searchText urlencode2];
    
    NSString *requestString = [NSString stringWithFormat:
                               @"https://%@/rApi/location/$name:%@", 
                               [[[RWSSettingsStore defaultStore] settings] clusterName],
                               encodedSearchText];
    
    DLog(@"encoded url = %@", requestString);

    
    NSURL *url = [NSURL URLWithString:requestString];
    
    // Set up the connection as normal
    //NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *password = [[[RWSSettingsStore defaultStore] settings] password];
    
    [req addValue:[self getAuthHeaderForUser:@"admin" password:password] forHTTPHeaderField:@"Authorization"];

    RWSChannel *channel = [[RWSChannel alloc] init];
    
    [channel setApiRequestType:SearchLocation];
    
    RWSConnection *connection = [[RWSConnection alloc] initWithRequest:req];
    [connection setCompletionBlock:block];
    [connection setJsonRootObject:channel];
    
    [connection start];
    
}

//Methd to get location from api for a given location id
- (void)fetchLocation:(int)locationId withCompletion:(void (^)(RWSChannel *obj, NSError *err))block
{
 
    DLog(@"In fetchLocation...");
    // Prepare a request URL, including the argument from the controller
    
    NSString *requestString = [NSString stringWithFormat:
                               @"https://%@/rApi/location/%d", 
                               [[[RWSSettingsStore defaultStore] settings] clusterName],
                               locationId];
    NSString *password = [[[RWSSettingsStore defaultStore] settings] password];
    
    DLog(@"requestString = %@", requestString);
    
    
    NSURL *url = [NSURL URLWithString:requestString];
    
    // Set up the connection as normal
    //NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req addValue:[self getAuthHeaderForUser:@"admin" password:password] forHTTPHeaderField:@"Authorization"];
    
    RWSChannel *channel = [[RWSChannel alloc] init];
    
    [channel setApiRequestType:GetLocationById];
    
    RWSConnection *connection = [[RWSConnection alloc] initWithRequest:req];
    [connection setCompletionBlock:block];
    [connection setJsonRootObject:channel];
    
    [connection start];
    
}


//Method to update scene status on a location
- (void)updateLocation:(int)locationId 
             sceneName:(NSString *)sceneName 
            withCompletion:(void (^)(RWSChannel *obj, NSError *err))block
{
    DLog(@"In updateLocation...");
    
    NSString *requestString = [NSString stringWithFormat:
                               @"https://%@/uApi", 
                               [[[RWSSettingsStore defaultStore] settings] clusterName]];
    NSString *password = [[[RWSSettingsStore defaultStore] settings] password];
    
    //Build JSON request string
    //post it to the URL
    //read response and load it to the channel (?)
    
    DLog(@"requestString = %@", requestString);
    NSURL *url = [NSURL URLWithString:requestString];
    
    // Set up the connection as normal
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    //setup additional request parameters
    [req setHTTPMethod:@"POST"];
    
    NSString *jsonReqStr = [self getJSONStringFromLocationId:locationId sceneName:sceneName];
    DLog(@"jsonReqStr = %@", jsonReqStr);
    [req setHTTPBody:[jsonReqStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    [req addValue:[self getAuthHeaderForUser:@"admin" password:password] forHTTPHeaderField:@"Authorization"];
    
    
    //Setup the output handler
    RWSChannel *channel = [[RWSChannel alloc] init];
    [channel setApiRequestType:UpdateLocation];

    RWSConnection *connection = [[RWSConnection alloc] initWithRequest:req];
    [connection setCompletionBlock:block];
    [connection setJsonRootObject:channel];
    
    [connection start];
        
}

- (NSString *)getJSONStringFromLocationId: (int)locId 
                                sceneName: (NSString *)scName
{
    //NSString *encodedSceneName = [scName urlencode];
    
    NSString *jsonTempl = @"{\"protocolVersion\" : \"1\", \"schemaVersion\" : \"1.3.0\", \"requestType\" : \"set\", \"requestData\" : { \"location\" : [{\"id\": %d,\"sceneControl\":{\"activeSceneName\": \"%@\"}}]}}";
    
    //NSString *jsonStr = [NSString stringWithFormat:jsonTempl,locId,encodedSceneName];
    NSString *jsonStr = [NSString stringWithFormat:jsonTempl,locId,scName];
    
    return jsonStr;
    
    
}

- (NSString *) getAuthHeaderForUser: (NSString *) userName
                           password: (NSString *) pwd
{
    NSString *s = [NSString stringWithFormat:@"%@:%@", userName, pwd];
    NSString *authHdr = [NSString stringWithFormat:@"Basic %@",[s newStringInBase64FromString]];
    
    return authHdr;
}


//Methd to get all locations using the unified api
//Filter out locations with location_id < 100
//Each location is shallow - only contains locationId, LocationName
- (void)fetchAllLocationsWithCompletion:(void (^)(RWSChannel *obj, NSError *err))block
{
    
    DLog(@"In fetchAllLocationsWithCompletion...");

    NSString *requestString = [NSString stringWithFormat:
                               @"https://%@/uApi", 
                               [[[RWSSettingsStore defaultStore] settings] clusterName]];
    NSString *password = [[[RWSSettingsStore defaultStore] settings] password];
    
    //Build JSON request string
    //post it to the URL
    //read response and load it to the channel (?)
    
    DLog(@"requestString = %@", requestString);
    NSURL *url = [NSURL URLWithString:requestString];
    
    // Set up the connection as normal
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    //setup additional request parameters
    [req setHTTPMethod:@"POST"];
    
    NSString *jsonReqStr = [self getJSONStringForAllLocations];
    DLog(@"jsonReqStr = %@", jsonReqStr);
    [req setHTTPBody:[jsonReqStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    [req addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    [req addValue:[self getAuthHeaderForUser:@"admin" password:password] forHTTPHeaderField:@"Authorization"];
    
    
    //Setup the output handler
    RWSChannel *channel = [[RWSChannel alloc] init];
    [channel setApiRequestType:GetAllLocations];
    
    RWSConnection *connection = [[RWSConnection alloc] initWithRequest:req];
    [connection setCompletionBlock:block];
    [connection setJsonRootObject:channel];
    
    [connection start];


}


- (NSString *)getJSONStringForAllLocations{
    
    NSString *jsonStr = @"{\"protocolVersion\" : \"1\", \"schemaVersion\" : \"1.3.0\", \"requestType\" : \"get\", \"requestData\" : { \"location\" : [{ \"name\":null }]}}";
        
    return jsonStr;
}





@end
