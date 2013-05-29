//
//  RWSSettings.m
//
//  Created by Vivek Phalak on 6/12/12.
//  Copyright (c) 2012 Redwood Systems Inc. All rights reserved.
//


#import "RWSSettings.h"
#import "RWSDebug.h"

@implementation RWSSettings

@synthesize userName,password,clusterName;
@synthesize lastPickedLocationId;
@synthesize shouldRefreshLocations;

- initWithName: (NSString *)clName user: (NSString *)usr password: (NSString *) pwd
{
    self = [super self];
    if (self) {
        [self setClusterName:clName];
        //[self setUserName:usr];
        [self setUserName:@"admin"];
        [self setPassword:pwd]; 
        [self setLastPickedLocationId:0];
        [self setShouldRefreshLocations:NO];
    }
    return self;
}

- (id)init
{
    return ([self initWithName:@"" user:@"admin" password:@""]);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:clusterName forKey:@"clusterName"];
    //[aCoder encodeObject:userName forKey:@"userName"];
    [aCoder encodeObject:@"admin" forKey:@"userName"];
    [aCoder encodeObject:password forKey:@"password"];
    [aCoder encodeInt:lastPickedLocationId forKey:@"lastPickedLocationId"];
    [aCoder encodeBool:shouldRefreshLocations forKey:@"shouldRefreshLocations"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setClusterName:[aDecoder decodeObjectForKey:@"clusterName"]];
        //[self setUserName:[aDecoder decodeObjectForKey:@"userName"]];
        [self setUserName:@"admin"];
        [self setPassword:[aDecoder decodeObjectForKey:@"password"]];
        [self setLastPickedLocationId:[aDecoder decodeIntForKey:@"lastPickedLocationId"]];
        [self setShouldRefreshLocations:[aDecoder decodeBoolForKey:@"shouldRefreshLocations"]];
    }
    return self;
}

- (NSString *)description
{
    NSString *descString = 
    [[NSString alloc] initWithFormat:@"Cluster: %@ Password:%@ Last Picked Loc: %d Should Refresh Locations %d", 
                clusterName, password, lastPickedLocationId, shouldRefreshLocations];
    
    return descString;
}



@end
