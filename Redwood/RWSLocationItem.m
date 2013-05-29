//
//  RWSLocationItem.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import "RWSLocationItem.h"
#import "RWSSceneItem.h"
#import "NSString+Encode.h"
#import "RWSDebug.h"

@implementation RWSLocationItem
@synthesize locationId, locationName, hasScenes, activeSceneName;
@synthesize lastActiveSceneName;
@synthesize scenes;


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:locationId forKey:@"locationId"];
    [aCoder encodeObject:locationName forKey:@"locationName"];
    [aCoder encodeBool:hasScenes forKey:@"hasScenes"];
    [aCoder encodeObject:activeSceneName forKey:@"activeSceneName"];
    [aCoder encodeObject:lastActiveSceneName forKey:@"lastActiveSceneName"];
    [aCoder encodeObject:scenes forKey:@"scenes"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setLocationId:[aDecoder decodeIntForKey:@"locationId"]];
        [self setLocationName:[aDecoder decodeObjectForKey:@"locationName"]];
        [self setHasScenes:[aDecoder decodeBoolForKey:@"hasScenes"]];
        [self setActiveSceneName:[aDecoder decodeObjectForKey:@"activeSceneName"]];
        [self setLastActiveSceneName:[aDecoder decodeObjectForKey:@"lastActiveSceneName"]];
        [self setScenes:[aDecoder decodeObjectForKey:@"scenes"]];
    }
    return self;
}


-(id) initWithLocationName:(NSString *) locName
                locationId: (int) locId
                 hasScenes: (BOOL) hasSc
                activeSceneName: (NSString *) actScName

{
    
    self = [super init];
    if (self) 
    {
        [self setLocationId:locId];
        [self setLocationName:locName];
        [self setHasScenes:hasSc];
        [self setActiveSceneName:actScName];
        [self setLastActiveSceneName:nil];
        [self setScenes:[[NSMutableArray alloc] initWithCapacity:30]]; //create an empty scene list
    }
    return self;
    
}

-(id) init
{
    return ([self initWithLocationName:@"Location" locationId:0 hasScenes:NO activeSceneName:nil]);
}

- (NSArray *) scenes
{
    return scenes;
}

- (void)readFromJSONDictionary:(NSDictionary *)d
{
    //TODO: Implement this method
    //Assumes d is in standard location json format
    if (!d){
        return;
    }
    
    DLog(@"d = %@",d);
    NSNumber *locId = [d objectForKey:@"id"];
    NSString *locName = [d objectForKey:@"name"];
    
    [self setLocationId:[locId intValue]];
    [self setLocationName:locName];        
    
    NSDictionary *sc = [d objectForKey:@"sceneControl"];
    
    if (sc) {
        NSString *actSceneName = [sc objectForKey:@"activeSceneName"];
        [self setActiveSceneName:actSceneName];
        
        NSArray *scList = [sc objectForKey:@"scene"];
        NSMutableArray *sceneArr = [[NSMutableArray alloc] initWithCapacity:30];
        
        for (int i=0; i < [scList count]; i++){
            NSString *scName = nil;
            BOOL isActScene = NO;
            NSDictionary *scDict = [scList objectAtIndex:i];
            
            if (scDict){
                scName = [scDict objectForKey:@"name"];
                isActScene = NO;
                if ([scName isEqualToString:[self activeSceneName]]){
                    isActScene = YES;
                }
                
                RWSSceneItem *sceneItem = [[RWSSceneItem alloc] 
                                           initWithSceneName:scName 
                                           locationId:[self locationId]
                                           location:self 
                                           isActive:isActScene
                                           order:[[scDict objectForKey:@"order"] intValue]
                                           ];
                [sceneArr addObject:sceneItem];
            }
        }
        
        [self setScenes:sceneArr];
        
    }
}


- (void)readFromJSONDictionaryAllLocations:(NSDictionary *)d
{
    //TODO: Implement this method
    //Assumes d is in json format returned by Unified API for all locations query
    if (!d){
        return;
    }
    
    DLog(@"d = %@",d);
    
    NSNumber *locId = [d objectForKey:@"id"];
    NSString *locName = [d objectForKey:@"name"];
    
    [self setLocationId:[locId intValue]];
    [self setLocationName:locName];        
    
}


- (void)readFromJSONObject:(NSObject *)d
{
    //TODO: Implement this method
    //Assumes d is in standard location json format
    if (d) {
        DLog(@"d = %@",d);
    }
}



@end
