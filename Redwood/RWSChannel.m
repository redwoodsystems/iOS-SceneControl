//
//  RWSChannel.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//

#import "RWSChannel.h"
#import "RWSLocationItem.h"
#import "RWSDebug.h"

@implementation RWSChannel
@synthesize items, apiRequestType, postJsonResponse;

- (void)readFromJSONObject:(NSObject *)d
{
    DLog(@"In readFromJSONObject: reqType: %d type=%@ d= %@",apiRequestType,[d class], d);
    if (d){
        //Build Location from dictionary and add it to the items array
        if ([d respondsToSelector:@selector(objectAtIndex:)]){
            DLog(@"This is an array");
            [self readFromJSONArray:(NSArray *) d];
        }
        
        if ([d respondsToSelector:@selector(objectForKey:)]){
            DLog(@"This is a dict");
            [self readFromJSONDictionary:(NSDictionary *)d];
        }
        

    }
    
}

- (void) readFromJSONDictionary:(NSDictionary *)d
{
    DLog(@"In readFromJSONDictionary");
    if (apiRequestType == GetLocationById){
        RWSLocationItem *location = [[RWSLocationItem alloc] init];
        [location readFromJSONDictionary:d];
        [[self items] addObject:location];
    }
    
    if (apiRequestType == UpdateLocation){
        NSString *retResponseType = [d objectForKey:@"responseType"];
        DLog(@"returned responseType = %@", retResponseType); 
        [self setPostJsonResponse:d];
    }
    
    if (apiRequestType == GetAllLocations){        
        NSString *retResponseType = [d objectForKey:@"responseType"];
        DLog(@"returned responseType = %@", retResponseType); 
        [self setPostJsonResponse:d];
        
        if ([retResponseType isEqualToString:@"errorResponse"]){
            return; 
        }

        NSDictionary *responseData = [d objectForKey:@"responseData"];
        if (responseData){
            NSArray *locationList = [responseData objectForKey:@"location"];
            
            NSNumber *locId = nil;
            for (int i=0;i <[locationList count]; i++){
                //create light weight location object
                //skip all locations with id < 100
                locId = [[locationList objectAtIndex:i] objectForKey:@"id"];
                if ([locId intValue] >= 100) {
                    RWSLocationItem *location = [[RWSLocationItem alloc] init];
                    [location readFromJSONDictionaryAllLocations:[locationList objectAtIndex:i]];
                    [[self items] addObject:location];                    
                }
            }            
        }
    }
    
        
}

- (void) readFromJSONArray: (NSArray *)d
{
    //get response element and delegate to RWSLocation to parse rest of dict
    if (apiRequestType == SearchLocation){
        NSDictionary *locationDict = nil;
        for (int i=0; i < [d count]; i++){
            DLog(@"loc: %@ %@",[d objectAtIndex:i], [[d objectAtIndex:i] class] );
            locationDict = [[d objectAtIndex:i] objectForKey:@"response"];
            RWSLocationItem *location = [[RWSLocationItem alloc] init];
            [location readFromJSONDictionary:locationDict];
            [[self items] addObject:location];
        }        
    }
        
}


- (id)init 
{
    self = [super init];
    
    if (self) {
        // Create the container for the RSSItems this channel has;
        // we'll create the RSSItem class shortly.
        items = [[NSMutableArray alloc] init];
    }
    
    return self;
}


@end
